import assert from "node:assert/strict";
import { spawnSync } from "node:child_process";
import { existsSync, mkdtempSync, rmSync } from "node:fs";
import { tmpdir } from "node:os";
import { join } from "node:path";
import { fileURLToPath } from "node:url";
import test from "node:test";
import {
  assertBrowserMode, readTmuxEnvironment, resolveBrowserBinary, resolveProfileSource,
} from "./browser-runtime.js";

for (const name of ["SSH_CONNECTION", "SSH_CLIENT", "SSH_TTY", "IS_SSH_SESSION"]) {
  test(`refuses headed mode for ${name}, even with a forwarded display`, () => {
    assert.throws(() => assertBrowserMode({
      env: { [name]: name === "IS_SSH_SESSION" ? "1" : "ssh", DISPLAY: "localhost:10" },
      platform: "linux",
    }), /SSH session detected.*start\.js --headless/);
  });
}

test("allows headless without inspecting tmux or requiring a display", () => {
  assertBrowserMode({
    headless: true, env: { SSH_CONNECTION: "ssh", TMUX: "invalid" }, platform: "linux",
    tmuxEnvironment: () => { throw new Error("must not be called"); },
  });
});

test("allows a local Mac desktop, including tmux without SSH", () => {
  assertBrowserMode({ env: {}, platform: "darwin" });
  assertBrowserMode({
    env: { TMUX: "/tmp/socket,1,2" }, platform: "darwin", tmuxEnvironment: () => ({}),
  });
});

test("ignores empty SSH variables and IS_SSH_SESSION=0", () => {
  assertBrowserMode({
    env: { SSH_CONNECTION: "", SSH_CLIENT: " ", SSH_TTY: "", IS_SSH_SESSION: "0" },
    platform: "darwin",
  });
});

test("checks the tmux session when the pane environment predates SSH attachment", () => {
  assert.throws(() => assertBrowserMode({
    env: { TMUX: "/tmp/socket,1,2" }, platform: "darwin",
    tmuxEnvironment: () => ({ SSH_CONNECTION: "remote" }),
  }), /SSH_CONNECTION in tmux session environment/);
});

test("fails closed if tmux environment inspection fails", () => {
  assert.throws(() => assertBrowserMode({
    env: { TMUX: "invalid" }, platform: "darwin",
    tmuxEnvironment: () => { throw new Error("unavailable"); },
  }), /Cannot check this tmux session.*--headless/);
});

test("requires a Linux display outside SSH, allowing either display protocol", () => {
  assert.throws(() => assertBrowserMode({ env: {}, platform: "linux" }), /No desktop display/);
  for (const name of ["DISPLAY", "WAYLAND_DISPLAY"]) {
    assertBrowserMode({ env: { [name]: "display" }, platform: "linux" });
  }
});

test("queries the exact tmux socket and session and ignores removed variables", () => {
  const env = readTmuxEnvironment({ TMUX: "/tmp/socket,with-comma,123,4" }, (command, args, options) => {
    assert.equal(command, "tmux");
    assert.deepEqual(args, ["-S", "/tmp/socket,with-comma", "show-environment", "-t", "$4"]);
    assert.equal(options.timeout, 2000);
    return "-SSH_TTY\nSSH_CONNECTION=client port server port\nDISPLAY=:0\nUNRELATED=a=b\n";
  });
  assert.equal(env.SSH_TTY, undefined);
  assert.equal(env.SSH_CONNECTION, "client port server port");
  assert.equal(env.UNRELATED, "a=b");
  assert.throws(() => readTmuxEnvironment({ TMUX: "invalid" }), /Invalid TMUX/);
});

test("discovers Brave on Mac and Chromium on Fedora's PATH", () => {
  const brave = "/Applications/Brave Browser.app/Contents/MacOS/Brave Browser";
  assert.equal(resolveBrowserBinary({
    env: {}, platform: "darwin", executable: (path) => path === brave,
  }), brave);
  assert.equal(resolveBrowserBinary({
    env: { PATH: "/usr/local/bin:/usr/bin" }, platform: "linux",
    executable: (path) => path === "/usr/bin/chromium",
  }), "/usr/bin/chromium");
});

test("finds user-installed Mac apps", () => {
  const path = "/home/test/Applications/Chromium.app/Contents/MacOS/Chromium";
  assert.equal(resolveBrowserBinary({
    env: { HOME: "/home/test" }, platform: "darwin", executable: (candidate) => candidate === path,
  }), path);
});

test("honors BROWSER_BIN as an executable path or command, with no silent fallback", () => {
  for (const value of ["/usr/bin/custom-browser", "custom-browser"]) {
    assert.equal(resolveBrowserBinary({
      env: { BROWSER_BIN: value, PATH: "/usr/bin" },
      executable: (path) => path === "/usr/bin/custom-browser",
    }), "/usr/bin/custom-browser");
  }
  assert.throws(() => resolveBrowserBinary({
    env: { BROWSER_BIN: "/missing" }, executable: () => false,
  }), /BROWSER_BIN is not an executable/);
  assert.throws(() => resolveBrowserBinary({
    env: {}, platform: "linux", executable: () => false,
  }), /Could not find/);
});

test("selects profile directories for the actual browser and respects XDG config", () => {
  const env = { HOME: "/home/test", XDG_CONFIG_HOME: "/config" };
  assert.equal(resolveProfileSource("/Applications/Brave Browser", { env, platform: "darwin" }),
    "/home/test/Library/Application Support/BraveSoftware/Brave-Browser");
  assert.equal(resolveProfileSource("/Applications/Google Chrome Canary", { env, platform: "darwin" }),
    "/home/test/Library/Application Support/Google/Chrome Canary");
  for (const [binary, directory] of [["chromium", "chromium"], ["google-chrome", "google-chrome"],
    ["brave-browser", "BraveSoftware/Brave-Browser"]]) {
    assert.equal(resolveProfileSource(`/usr/bin/${binary}`, { env, platform: "linux" }), `/config/${directory}`);
  }
  assert.equal(resolveProfileSource("/unknown", {
    env: { BROWSER_PROFILE_SOURCE: "/explicit" }, platform: "linux",
  }), "/explicit");
  assert.throws(() => resolveProfileSource("/unknown", { env, platform: "linux" }), /BROWSER_PROFILE_SOURCE/);
});

const scriptDir = fileURLToPath(new URL(".", import.meta.url));
const start = join(scriptDir, existsSync(join(scriptDir, "start.js")) ? "start.js" : "executable_start.js");
const cleanEnv = () => Object.fromEntries(Object.entries(process.env).filter(([name]) =>
  !["SSH_CONNECTION", "SSH_CLIENT", "SSH_TTY", "IS_SSH_SESSION", "TMUX", "TMUX_PANE", "BROWSER_CACHE_DIR"].includes(name)));

test("cache overrides isolate browser and log state without changing HOME", () => {
  const module = new URL("browser-paths.js", import.meta.url).href;
  const code = `const paths = await import(${JSON.stringify(module)}); console.log(JSON.stringify(paths));`;
  for (const cache of [undefined, "/tmp/isolated-agent-web"]) {
    const env = { ...cleanEnv(), HOME: "/home/test" };
    if (cache) env.BROWSER_CACHE_DIR = cache;
    const result = spawnSync(process.execPath, ["--input-type=module", "-e", code], { env, encoding: "utf8" });
    assert.equal(result.status, 0, result.stderr);
    const paths = JSON.parse(result.stdout);
    const root = cache || "/home/test/.cache/agent-web";
    assert.deepEqual(paths, { CACHE_ROOT: root, BROWSER_ROOT: `${root}/browser`, LOG_ROOT: `${root}/logs` });
  }
});

test("CLI refuses SSH before resetting a profile or inspecting an endpoint", () => {
  const home = mkdtempSync(join(tmpdir(), "web-browser-guard-"));
  try {
    const result = spawnSync(process.execPath, [start, "--reset-profile"], {
      env: { ...cleanEnv(), HOME: home, SSH_CONNECTION: "test", BROWSER_BIN: "/missing" }, encoding: "utf8",
    });
    assert.equal(result.status, 1);
    assert.match(result.stderr, /SSH session detected.*--headless/);
    assert.equal(existsSync(join(home, ".cache")), false);
    const headless = spawnSync(process.execPath, [start, "--headless"], {
      env: { ...cleanEnv(), HOME: home, SSH_CONNECTION: "test", BROWSER_BIN: "/missing" }, encoding: "utf8",
    });
    assert.equal(headless.status, 1);
    assert.match(headless.stderr, /BROWSER_BIN is not an executable/);
    assert.doesNotMatch(headless.stderr, /SSH session detected/);
  } finally {
    rmSync(home, { recursive: true, force: true });
  }
});

test("CLI detects SSH in a real isolated tmux session, without inherited SSH variables", (t) => {
  if (spawnSync("tmux", ["-V"]).error) return t.skip("tmux is not installed");
  const home = mkdtempSync(join(tmpdir(), "web-browser-tmux-"));
  const socket = join(home, "tmux.sock");
  const run = (args) => {
    const result = spawnSync("tmux", ["-S", socket, ...args], { env: cleanEnv(), encoding: "utf8" });
    assert.equal(result.status, 0, result.stderr);
    return result.stdout.trim();
  };
  try {
    run(["-f", "/dev/null", "new-session", "-d", "-s", "guard", "sleep 60"]);
    const session = run(["display-message", "-p", "-t", "guard", "#{session_id}"]);
    const pid = run(["display-message", "-p", "-t", "guard", "#{pid}"]);
    run(["set-environment", "-t", "guard", "SSH_CONNECTION", "test"]);
    const result = spawnSync(process.execPath, [start], {
      env: { ...cleanEnv(), HOME: home, TMUX: `${socket},${pid},${session.slice(1)}`, BROWSER_BIN: "/missing" },
      encoding: "utf8",
    });
    assert.equal(result.status, 1);
    assert.match(result.stderr, /SSH_CONNECTION in tmux session environment/);
    assert.equal(existsSync(join(home, ".cache")), false);
  } finally {
    spawnSync("tmux", ["-S", socket, "kill-server"]);
    rmSync(home, { recursive: true, force: true });
  }
});

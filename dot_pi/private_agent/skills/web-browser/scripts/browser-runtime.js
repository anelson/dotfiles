import { execFileSync } from "node:child_process";
import { accessSync, constants, statSync } from "node:fs";
import { homedir } from "node:os";
import { delimiter, join, resolve } from "node:path";

const SSH_VARIABLES = ["SSH_CONNECTION", "SSH_CLIENT", "SSH_TTY"];

export function sshIndicator(env) {
  return SSH_VARIABLES.find((name) => env[name]?.trim()) ||
    (env.IS_SSH_SESSION === "1" ? "IS_SSH_SESSION" : null);
}

export function readTmuxEnvironment(env, run = execFileSync) {
  // TMUX contains the socket, server PID, and session ID. Query the session,
  // not the global environment: another session can have a different client.
  const match = env.TMUX?.match(/^(.*),\d+,(\d+)$/);
  if (!match) throw new Error("Invalid TMUX environment variable");
  const output = run("tmux", [
    "-S", match[1], "show-environment", "-t", `$${match[2]}`,
  ], { encoding: "utf8", timeout: 2000, stdio: ["ignore", "pipe", "pipe"] });
  const result = {};
  for (const line of output.split("\n")) {
    const index = line.indexOf("=");
    if (index > 0) result[line.slice(0, index)] = line.slice(index + 1);
  }
  return result;
}

export function assertBrowserMode({
  headless = false,
  env = process.env,
  platform = process.platform,
  tmuxEnvironment = readTmuxEnvironment,
} = {}) {
  if (headless) return;
  let indicator = sshIndicator(env);
  let location = "process environment";
  if (!indicator && env.TMUX) {
    let sessionEnv;
    try {
      sessionEnv = tmuxEnvironment(env);
    } catch {
      throw new Error(
        "Cannot check this tmux session for SSH. Refusing a visible browser; run start.js --headless.",
      );
    }
    indicator = sshIndicator(sessionEnv);
    location = "tmux session environment";
  }
  if (indicator) {
    throw new Error(
      `SSH session detected (${indicator} in ${location}). Visible browsers are disabled over SSH, even with display forwarding. Run start.js --headless.`,
    );
  }
  if (platform === "linux" && !env.DISPLAY?.trim() && !env.WAYLAND_DISPLAY?.trim()) {
    throw new Error(
      "No desktop display detected (DISPLAY and WAYLAND_DISPLAY are unset). Run start.js --headless.",
    );
  }
}

function isExecutable(path) {
  try {
    accessSync(path, constants.X_OK);
    return statSync(path).isFile();
  } catch {
    return false;
  }
}

export function resolveBrowserBinary({
  env = process.env,
  platform = process.platform,
  home = env.HOME || homedir(),
  executable = isExecutable,
} = {}) {
  const findOnPath = (name) => (env.PATH || "").split(delimiter)
    .filter(Boolean).map((dir) => resolve(dir, name)).find(executable);
  if (env.BROWSER_BIN) {
    const path = env.BROWSER_BIN.includes("/")
      ? resolve(env.BROWSER_BIN) : findOnPath(env.BROWSER_BIN);
    if (!path || !executable(path)) {
      throw new Error("BROWSER_BIN is not an executable file. Set it to a Chrome, Chromium, or Brave binary.");
    }
    return path;
  }
  if (platform === "darwin") {
    const apps = [
      "Google Chrome.app/Contents/MacOS/Google Chrome",
      "Chromium.app/Contents/MacOS/Chromium",
      "Brave Browser.app/Contents/MacOS/Brave Browser",
      "Google Chrome Canary.app/Contents/MacOS/Google Chrome Canary",
    ];
    for (const root of ["/Applications", join(home, "Applications")]) {
      const path = apps.map((app) => join(root, app)).find(executable);
      if (path) return path;
    }
  }
  for (const name of [
    "google-chrome-stable", "google-chrome", "chromium", "chromium-browser",
    "brave-browser", "brave-browser-stable",
  ]) {
    const path = findOnPath(name);
    if (path) return path;
  }
  throw new Error("Could not find Chrome, Chromium, or Brave. Install one or set BROWSER_BIN=/path/to/browser.");
}

export function resolveProfileSource(binary, {
  env = process.env,
  platform = process.platform,
  home = env.HOME || homedir(),
} = {}) {
  if (env.BROWSER_PROFILE_SOURCE) return resolve(env.BROWSER_PROFILE_SOURCE);
  const name = binary.toLowerCase();
  const browser = name.includes("brave") ? "brave" :
    name.includes("chromium") ? "chromium" :
    name.includes("chrome") ? "chrome" : null;
  if (platform === "darwin") {
    const directories = {
      brave: ["BraveSoftware", "Brave-Browser"],
      chromium: ["Chromium"],
      chrome: ["Google", name.includes("canary") ? "Chrome Canary" : "Chrome"],
    };
    if (browser) return join(home, "Library", "Application Support", ...directories[browser]);
  }
  if (platform === "linux") {
    const directories = {
      brave: ["BraveSoftware", "Brave-Browser"],
      chromium: ["chromium"],
      chrome: ["google-chrome"],
    };
    if (browser) return join(env.XDG_CONFIG_HOME || join(home, ".config"), ...directories[browser]);
  }
  throw new Error("Cannot locate this browser's profile. Set BROWSER_PROFILE_SOURCE to its user-data directory.");
}

import assert from "node:assert/strict";
import { execFile } from "node:child_process";
import { existsSync, mkdtempSync, readFileSync, rmSync } from "node:fs";
import { createServer } from "node:http";
import { tmpdir } from "node:os";
import { join } from "node:path";
import { fileURLToPath } from "node:url";
import { promisify } from "node:util";
import test from "node:test";
import { resolveBrowserBinary } from "./browser-runtime.js";

const exec = promisify(execFile);
const dir = fileURLToPath(new URL(".", import.meta.url));
const enabled = process.env.BROWSER_SMOKE_TEST === "1";
const headed = process.env.BROWSER_SMOKE_HEADED === "1";

async function listen(server) {
  await new Promise((resolve, reject) => {
    server.once("error", reject);
    server.listen(0, "127.0.0.1", resolve);
  });
  return server.address().port;
}

const html = `<!doctype html><html><head><title>Pi browser smoke test</title>
<meta name="viewport" content="width=device-width, initial-scale=1"></head>
<body style="font:20px sans-serif;padding:40px"><h1>Pi browser smoke test</h1>
<p>This is an isolated test browser. It does not use your personal profile.</p>
<button id="button" onclick="this.textContent='Clicked';console.log('smoke click')">Click me</button>
<div id="onetrust-banner-sdk"><button id="onetrust-reject-all-handler"
 onclick="document.getElementById('onetrust-banner-sdk').remove()">Reject all cookies</button></div>
</body></html>`;

test("real browser navigation, interaction, screenshots, logging, and mode switching", {
  skip: enabled ? false : "set BROWSER_SMOKE_TEST=1 to launch an isolated browser",
  timeout: 120000,
}, async () => {
  assert.ok(existsSync(join(dir, "start.js")), "Run smoke tests from the deployed skill, not the chezmoi source tree");
  const home = mkdtempSync(join(tmpdir(), "web-browser-smoke-"));
  const fixture = createServer((request, response) => {
    response.statusCode = request.url === "/json/version" ? 404 : 200;
    response.setHeader("Content-Type", "text/html");
    response.end(html);
  });
  const portReservation = createServer();
  const screenshots = [];
  let env;
  const run = async (name, args = [], overrides = {}) => {
    const result = await exec(process.execPath, [join(dir, `${name}.js`), ...args], {
      env: { ...env, ...overrides }, timeout: 45000,
    });
    return result.stdout.trim();
  };
  const reject = async (name, args, pattern, overrides = {}) => {
    await assert.rejects(run(name, args, overrides), (error) => {
      assert.equal(error.code, 1);
      assert.match(error.stderr, pattern);
      return true;
    });
  };
  try {
    const fixturePort = await listen(fixture);
    const browserPort = await listen(portReservation);
    await new Promise((resolve) => portReservation.close(resolve));
    env = { ...process.env, BROWSER_CACHE_DIR: join(home, "agent-web"), BROWSER_DEBUG_HOST: "127.0.0.1",
      BROWSER_DEBUG_PORT: String(browserPort), BROWSER_BIN: resolveBrowserBinary() };
    const url = `http://127.0.0.1:${fixturePort}/`;

    assert.match(await run("start", ["--headless"]), /started.*headless/);
    assert.match(await run("start", ["--headless"]), /already running/);
    assert.match(await run("start", ["--headless"], { SSH_CONNECTION: "test" }), /already running/);
    await reject("start", [], /SSH session detected.*--headless/, { SSH_CONNECTION: "test" });
    await reject("start", ["--headless", "--reset-profile"], /Run stop\.js first/);
    await reject("start", ["--headless"], /Profile is in use/, { BROWSER_DEBUG_PORT: String(fixturePort) });
    // Exercise the headless-browser check even when the smoke test itself runs
    // over SSH or inside a tmux session attached through SSH.
    const localEnvironment = {
      SSH_CONNECTION: "", SSH_CLIENT: "", SSH_TTY: "", IS_SSH_SESSION: "0", TMUX: "", DISPLAY: ":test",
    };
    await reject("pick", ["Select something"], /requires a visible browser/, localEnvironment);
    await reject("pick", ["Select something"], /SSH session detected/, { SSH_CONNECTION: "test" });

    await run("nav", [url]);
    assert.equal(await run("eval", ["document.title"]), "Pi browser smoke test");
    assert.equal(await run("eval", ['document.querySelector("#button").click(); document.querySelector("#button").textContent']), "Clicked");
    assert.equal(await run("eval", ["await Promise.resolve(document.title)"]), "Pi browser smoke test");
    await run("eval", ['document.cookie="smoke=persisted;path=/;Max-Age=3600"; "saved"']);
    assert.match(await run("dismiss-cookies", ["--reject"]), /Dismissed cookie dialog/);
    for (const args of [[], ["--full-page"], ["--device", "pixel-7"]]) {
      const screenshot = await run("screenshot", args);
      screenshots.push(screenshot);
      assert.equal(readFileSync(screenshot).subarray(0, 8).toString("hex"), "89504e470d0a1a0a");
    }
    await run("emulate", ["iphone-14"]);
    assert.equal(await run("eval", ["window.innerWidth"]), "390");
    await run("emulate", ["--reset"]);
    await run("nav", [url, "--new"]);
    assert.match(await run("logs-tail"), /target\.attached/);
    assert.match(await run("net-summary"), /responses: [1-9]/);
    assert.match(await run("stop"), /browser stopped/);

    if (headed) {
      // Keep the real SSH/tmux environment. Do not bypass the visible-mode guard.
      assert.match(await run("start"), /started.*headed/);
      await run("nav", [url]);
      assert.match(await run("eval", ["document.cookie"]), /smoke=persisted/);
      await reject("start", ["--headless"], /Run stop\.js first/);
      const { stdout } = await exec(process.execPath, ["--input-type=module", "-e", `
        const { connect } = await import(${JSON.stringify(new URL("cdp.js", import.meta.url).href)});
        const cdp = await connect();
        const pages = await cdp.getPages();
        const { windowId, bounds } = await cdp.send("Browser.getWindowForTarget", { targetId: pages.at(-1).targetId });
        console.log(JSON.stringify({ windowId, bounds }));
        cdp.close();
      `], { env, timeout: 10000 });
      const window = JSON.parse(stdout);
      assert.ok(window.windowId > 0);
      assert.equal(window.bounds.windowState, "normal");
      console.log(`Visible browser window confirmed: ${window.bounds.width}x${window.bounds.height}`);
      assert.match(await run("stop"), /browser stopped/);
    }
    assert.match(await run("start", ["--headless"]), /started.*headless/);
    await run("nav", [url]);
    assert.match(await run("eval", ["document.cookie"]), /smoke=persisted/);
    assert.match(await run("stop"), /browser stopped/);
  } finally {
    if (env) await run("stop", ["--all"]).catch(() => {});
    await new Promise((resolve) => fixture.close(resolve));
    portReservation.close();
    for (const path of screenshots) rmSync(path, { force: true });
    rmSync(home, { recursive: true, force: true });
  }
});

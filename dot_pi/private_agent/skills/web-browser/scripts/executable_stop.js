#!/usr/bin/env node

// Modified from mitsuhiko/agent-stuff: shared cache and graceful CDP shutdown to flush cookies.
import { join } from "node:path";
import { findBrowserProcesses } from "./browser-processes.js";
import { BROWSER_ROOT } from "./browser-paths.js";
import { connect } from "./cdp.js";

const args = process.argv.slice(2);
if (args.some((arg) => arg !== "--all")) {
  console.error("Usage: stop.js [--all]");
  console.error("Stops the skill browser on BROWSER_DEBUG_PORT (default 9222).");
  console.error("--all stops skill browsers on every port, including headed ones.");
  process.exit(1);
}
const port = Number(process.env.BROWSER_DEBUG_PORT || 9222);
if (!Number.isInteger(port) || port < 1 || port > 65535) {
  console.error("✗ Invalid BROWSER_DEBUG_PORT (expected 1-65535)");
  process.exit(1);
}
const dirs = [join(BROWSER_ROOT, "fresh-profile"), join(BROWSER_ROOT, "profile-copy")];
const browsers = findBrowserProcesses(dirs).filter(
  (browser) => args.includes("--all") || browser.port === port,
);
if (!browsers.length) {
  console.log("✓ No matching skill browser is running");
  process.exit(0);
}

function stillOwned(browser) {
  return findBrowserProcesses(dirs).some((current) =>
    current.pid === browser.pid && current.userDataDir === browser.userDataDir &&
    current.port === browser.port);
}

for (const browser of browsers) {
  // Never trust state.json or a port alone. Check the process and the endpoint's
  // own launch arguments before closing it. Browser.close flushes cookie writes;
  // SIGTERM alone can lose writes made shortly before stopping on macOS.
  if (!stillOwned(browser)) continue;
  let closed = false;
  let cdp;
  if (browser.port) {
    try {
      cdp = await connect(2000, { host: "127.0.0.1", port: browser.port });
      const { arguments: args } = await cdp.send("Browser.getBrowserCommandLine", {}, null, 2000);
      if (args.includes(`--user-data-dir=${browser.userDataDir}`) &&
          args.includes(`--remote-debugging-port=${browser.port}`) && stillOwned(browser)) {
        await cdp.send("Browser.close", {}, null, 2000);
        closed = true;
      }
    } catch {
      // An unavailable endpoint still permits SIGTERM after revalidating the
      // process. Never use SIGKILL or remove a running browser's profile locks.
    } finally {
      cdp?.close();
    }
  }
  if (!closed && stillOwned(browser)) {
    console.error(`  CDP shutdown unavailable for PID ${browser.pid}; using SIGTERM (recent browser state may not be saved).`);
    try {
      process.kill(browser.pid, "SIGTERM");
    } catch (error) {
      if (error.code !== "ESRCH") throw error;
    }
  }
}

for (let i = 0; i < 40; i++) {
  const remaining = findBrowserProcesses(dirs).filter((current) =>
    browsers.some((browser) => browser.pid === current.pid));
  if (!remaining.length) {
    console.log("✓ Skill browser stopped; cached profiles preserved");
    process.exit(0);
  }
  await new Promise((resolve) => setTimeout(resolve, 250));
}
console.error("✗ Browser has not exited yet. Not forcing shutdown to avoid profile corruption.");
process.exit(1);

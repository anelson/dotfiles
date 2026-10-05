#!/usr/bin/env node

// Modified from mitsuhiko/agent-stuff: SSH guard, browser discovery, cache isolation, and launch diagnostics.
import { spawn, execFileSync } from "node:child_process";
import { closeSync, existsSync, mkdirSync, openSync, readFileSync, rmSync, statSync, writeFileSync } from "node:fs";
import { dirname, join } from "node:path";
import { fileURLToPath } from "node:url";
import { findBrowserProcesses } from "./browser-processes.js";
import { assertBrowserMode, resolveBrowserBinary, resolveProfileSource } from "./browser-runtime.js";
import { BROWSER_ROOT, CACHE_ROOT } from "./browser-paths.js";

const DEBUG_HOST = process.env.BROWSER_DEBUG_HOST || "localhost";
const DEBUG_PORT = Number(process.env.BROWSER_DEBUG_PORT || 9222);

if (!Number.isInteger(DEBUG_PORT) || DEBUG_PORT < 1 || DEBUG_PORT > 65535) {
  console.error("✗ Invalid BROWSER_DEBUG_PORT (expected 1-65535)");
  process.exit(1);
}

const args = new Set(process.argv.slice(2));
const headless = args.has("--headless");
const useProfile = args.has("--profile");
const resetProfile = args.has("--reset-profile");

const unknownArgs = [...args].filter(
  (arg) =>
    arg !== "--headless" && arg !== "--profile" && arg !== "--reset-profile",
);
if (unknownArgs.length > 0) {
  console.log("Usage: start.js [--headless] [--profile] [--reset-profile]");
  console.log("\nOptions:");
  console.log("  --headless      Run Chrome without opening a visible window");
  console.log(
    "  --profile       Copy your default Chrome profile into an isolated cache",
  );
  console.log("  --reset-profile Clear the selected cached profile before launch");
  console.log("\nExamples:");
  console.log("  start.js --headless");
  console.log("  start.js");
  console.log("  start.js --headless --profile");
  console.log("  start.js --headless --reset-profile");
  process.exit(1);
}

// Check before endpoint reuse, profile reset/copy, or any browser launch.
try {
  assertBrowserMode({ headless });
} catch (error) {
  console.error(`✗ ${error.message}`);
  process.exit(1);
}

const FRESH_PROFILE_DIR = join(BROWSER_ROOT, "fresh-profile");
const PROFILE_COPY_DIR = join(BROWSER_ROOT, "profile-copy");
const STATE_FILE = join(BROWSER_ROOT, "state.json");

const mode = useProfile ? "profile-copy" : "fresh";
const userDataDir = useProfile ? PROFILE_COPY_DIR : FRESH_PROFILE_DIR;

function ensureDir(path) {
  if (!existsSync(path)) {
    mkdirSync(path, { recursive: true, mode: 0o700 });
  }
}

function isProcessAlive(pid) {
  if (!pid || typeof pid !== "number") return false;
  try {
    process.kill(pid, 0);
    return true;
  } catch {
    return false;
  }
}

function readState() {
  if (!existsSync(STATE_FILE)) return null;
  try {
    return JSON.parse(readFileSync(STATE_FILE, "utf8"));
  } catch {
    return null;
  }
}

function writeState(state) {
  ensureDir(BROWSER_ROOT);
  writeFileSync(STATE_FILE, `${JSON.stringify(state, null, 2)}\n`);
}

function clearState() {
  try {
    rmSync(STATE_FILE, { force: true });
  } catch {
    // ignore
  }
}

async function isDebugEndpointUp() {
  try {
    const response = await fetch(
      `http://${DEBUG_HOST}:${DEBUG_PORT}/json/version`,
      { signal: AbortSignal.timeout(1000) },
    );
    return response.ok;
  } catch {
    return false;
  }
}

let chromeBinary;
let sourceProfileDir;
try {
  chromeBinary = resolveBrowserBinary();
  if (useProfile) {
    sourceProfileDir = resolveProfileSource(chromeBinary);
    if (!existsSync(sourceProfileDir) || !statSync(sourceProfileDir).isDirectory()) {
      throw new Error(`Could not find a browser profile at ${sourceProfileDir}. Set BROWSER_PROFILE_SOURCE to its user-data directory.`);
    }
    if (sourceProfileDir === userDataDir || sourceProfileDir.startsWith(`${CACHE_ROOT}/`)) {
      throw new Error("BROWSER_PROFILE_SOURCE must be outside the skill cache.");
    }
  }
} catch (error) {
  console.error(`✗ ${error.message}`);
  process.exit(1);
}

ensureDir(BROWSER_ROOT);

const state = readState();
if (state?.pid && !isProcessAlive(state.pid)) {
  clearState();
}

if (await isDebugEndpointUp()) {
  const runningState = readState();

  if (
    runningState?.pid &&
    isProcessAlive(runningState.pid) &&
    runningState.port === DEBUG_PORT
  ) {
    const runningHeadless = runningState.headless === true;
    const runningExtensionsDisabled =
      runningState.extensionsDisabled === true;
    if (
      !resetProfile &&
      runningState.mode === mode &&
      runningState.userDataDir === userDataDir &&
      runningState.browserBinary === chromeBinary &&
      runningHeadless === headless &&
      runningExtensionsDisabled === headless
    ) {
      console.log(
        `✓ Chrome already running on :${DEBUG_PORT} (${headless ? "headless" : "headed"}, ${mode} profile)`,
      );
      process.exit(0);
    }

    console.error(
      `✗ Chrome already running on :${DEBUG_PORT} (${runningHeadless ? "headless" : "headed"}, ${runningState.mode} profile)`,
    );
    console.error("  Run stop.js first before switching modes or resetting the profile.");
    process.exit(1);
  }

  console.error(`✗ Debugging endpoint :${DEBUG_PORT} is already in use`);
  console.error(
    "  Refusing to reuse unknown instance to avoid attaching to your regular profile.",
  );
  console.error(
    `  Close the process using :${DEBUG_PORT} or set BROWSER_DEBUG_PORT to a different port.`,
  );
  process.exit(1);
}

// A different port can still belong to the same profile. Check before any
// reset/copy, and leave Chrome's Singleton locks intact as a final safeguard.
const owners = findBrowserProcesses([userDataDir]);
if (owners.length > 0) {
  console.error(`✗ Profile is in use: ${userDataDir}`);
  for (const owner of owners) {
    console.error(`  PID ${owner.pid}, debugging port ${owner.port ?? "unknown"}`);
  }
  console.error("  Run stop.js first. Changing ports does not isolate profiles.");
  process.exit(1);
}

if (resetProfile) {
  rmSync(userDataDir, { recursive: true, force: true });
}
ensureDir(userDataDir);

if (useProfile) {
  try {
    execFileSync("rsync", [
      "-a", "--delete", "--exclude=Singleton*", "--exclude=DevToolsActivePort*",
      `${sourceProfileDir}/`, `${userDataDir}/`,
    ], { stdio: "pipe" });
  } catch (error) {
    console.error(`✗ Could not copy the browser profile: ${error.message}`);
    process.exit(1);
  }
}

for (const staleFile of [
  "DevToolsActivePort",
  "DevToolsActivePort.lock",
]) {
  try {
    rmSync(join(userDataDir, staleFile), { force: true });
  } catch {
    // ignore
  }
}

const chromeArgs = [
  "--remote-debugging-address=127.0.0.1",
  `--remote-debugging-port=${DEBUG_PORT}`,
  `--user-data-dir=${userDataDir}`,
  "--profile-directory=Default",
  "--disable-search-engine-choice-screen",
  "--no-first-run",
  "--no-default-browser-check",
  "--disable-features=ProfilePicker",
  "--enable-automation",
];

if (headless) {
  // Profile copies may contain extensions that depend on headed-only native
  // integrations. Keep their data in the copy, but do not load them in
  // headless automation.
  chromeArgs.push("--headless", "--disable-extensions");
}

const launchLog = join(BROWSER_ROOT, "launch.log");
const logFd = openSync(launchLog, "w", 0o600);
const chromeProc = spawn(chromeBinary, chromeArgs, {
  detached: true,
  stdio: ["ignore", logFd, logFd],
});
closeSync(logFd);
let launchError = null;
chromeProc.on("error", (error) => { launchError = error; });
chromeProc.unref();

let connected = false;
for (let i = 0; i < 30; i++) {
  if (await isDebugEndpointUp()) {
    connected = true;
    break;
  }
  if (launchError || chromeProc.exitCode !== null || chromeProc.signalCode !== null) break;
  await new Promise((r) => setTimeout(r, 500));
}

if (!connected) {
  chromeProc.kill("SIGTERM");
  console.error(`✗ Failed to connect to the browser on :${DEBUG_PORT}`);
  console.error(`  Attempted binary: ${chromeBinary}`);
  if (launchError) console.error(`  ${launchError.message}`);
  console.error(`  Browser output: ${launchLog}`);
  process.exit(1);
}

writeState({
  pid: chromeProc.pid,
  browserBinary: chromeBinary,
  mode,
  headless,
  extensionsDisabled: headless,
  userDataDir,
  port: DEBUG_PORT,
  startedAt: new Date().toISOString(),
});

const scriptDir = dirname(fileURLToPath(import.meta.url));
const watcherPath = join(scriptDir, "watch.js");
spawn(process.execPath, [watcherPath], { detached: true, stdio: "ignore" }).unref();

console.log(
  `✓ Chrome started on :${DEBUG_PORT} in ${headless ? "headless" : "headed"} mode with ${useProfile ? "profile-copy" : "fresh"} profile`,
);
if (!useProfile) {
  console.log(`  profile dir: ${userDataDir}`);
}

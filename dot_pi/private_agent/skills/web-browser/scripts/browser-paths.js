import { homedir } from "node:os";
import { join, resolve } from "node:path";

// Keep HOME unchanged for desktop services such as the macOS keychain. Tests
// and concurrent sessions can isolate all skill state with BROWSER_CACHE_DIR.
export const CACHE_ROOT = process.env.BROWSER_CACHE_DIR
  ? resolve(process.env.BROWSER_CACHE_DIR)
  : join(process.env.HOME || homedir(), ".cache", "agent-web");
export const BROWSER_ROOT = join(CACHE_ROOT, "browser");
export const LOG_ROOT = join(CACHE_ROOT, "logs");

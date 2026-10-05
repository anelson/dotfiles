# Upstream source

Adapted from Armin Ronacher's (mitsuhiko) `agent-stuff` web-browser skill:

- Repository: <https://github.com/mitsuhiko/agent-stuff>
- Directory: `skills/web-browser`
- Revision: `0865c849befd2021490679f96a8dee58c84ac857`

## Local changes

- `SKILL.md`: dependency setup, desktop collaboration, mandatory headless mode
  over SSH, Linux display checks, browser selection, and private-state guidance.
- `scripts/start.js`: enforce the SSH/display rule before side effects, discover
  macOS and Linux browsers, copy the matching browser's profile with argument-safe
  rsync, bound endpoint probes, and save browser launch diagnostics.
- `scripts/pick.js`: refuse SSH and headless browsers instead of waiting for a
  person who cannot interact with the page.
- `scripts/browser-runtime.js` and its tests: shared environment checks and
  browser/profile discovery, including the current tmux session's environment.
- `scripts/browser-smoke.test.js`: opt-in real-browser checks using only a
  temporary profile and a local test page.
- `scripts/browser-paths.js`, `stop.js`, `emulation-state.js`, `watch.js`,
  `logs-tail.js`, and `net-summary.js`: share `BROWSER_CACHE_DIR` so isolated
  sessions do not need to change `HOME` or disrupt macOS keychain access.
- `scripts/stop.js` and `cdp.js`: close owned browsers with CDP `Browser.close`
  before falling back to `SIGTERM`. On this Mac, SIGTERM lost recent cookie
  writes; Browser.close preserved them across a restart.

The remaining scripts and the npm dependency lock are copied unchanged. Chezmoi source
filenames use `executable_` for command-line scripts; deployed names match upstream.

# Upstream source

Adapted from Armin Ronacher's (mitsuhiko) `agent-stuff` web-browser skill:

- Repository: <https://github.com/mitsuhiko/agent-stuff>
- Directory: `skills/web-browser`
- Revision: `0865c849befd2021490679f96a8dee58c84ac857`
- License: Apache License 2.0; included in `LICENSE`.

The upstream skill's frontmatter said `license: Stolen from Mario`. This
adaptation uses the repository's actual Apache-2.0 license and retains the
upstream attribution here.

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

## Verification

Verified on macOS with Brave, running as the desktop user inside tmux:

- 20 unit/CLI checks passed, including an isolated real tmux session with SSH
  variables absent from the child process but present in the session environment.
- The opt-in browser smoke test passed: headless startup, navigation, JavaScript
  interaction, screenshots, mobile emulation, cookie-dialog rejection, logs,
  visible-window startup, and persistent cookies across mode switches.
- Pi discovered the deployed skill without diagnostics, and chezmoi source and
  live state matched after applying.

The user also confirmed that the separate visible Brave window appeared, and
that the missing-keychain error stopped after the tests kept the normal HOME.
Fedora runtime verification remains a follow-up; the tests here only simulate
Linux discovery and display environments.

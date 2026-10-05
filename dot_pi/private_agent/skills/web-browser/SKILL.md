---
name: web-browser
description: "Automate web pages with Chrome, Chromium, or Brave: navigate, click, fill forms, inspect content, take screenshots, and debug console or network activity. Use when a real browser is needed, including local desktop interaction. Prefer headless unless a person needs the window; SSH sessions require --headless, including inside tmux."
license: Stolen from Armin (who stole it from Mario)
compatibility: Requires Node.js 22 or later, npm, and Chrome, Chromium, or Brave. Profile copying also requires rsync. Inside tmux, visible mode requires tmux environment inspection.
---

# Web Browser

Local adaptation of [mitsuhiko/agent-stuff](https://github.com/mitsuhiko/agent-stuff/tree/main/skills/web-browser).
Modified for macOS desktop use and headless SSH sessions. See [UPSTREAM.md](UPSTREAM.md) for the source revision and changes.

Resolve all `./scripts/` paths relative to this skill directory, not the working directory.

## Setup

Install the script dependencies once per machine, from this skill directory:

```bash
npm --prefix ./scripts ci --ignore-scripts --no-audit --no-fund
```

Do not install dependencies in the chezmoi source tree. Use the deployed skill at
`~/.pi/agent/skills/web-browser`. Runtime dependencies, profiles, cookies, and logs
are machine-local and must not be added to dotfiles.

The launcher finds Chrome, Chromium, or Brave in `/Applications` or
`~/Applications` on macOS, and on `PATH` on Linux. On Fedora, install Chromium
with `sudo dnf install chromium` if no supported browser is already installed.
Do not run the browser as root or disable its sandbox to work around a launch failure.

## Tests

From the deployed skill directory:

```bash
node --test ./scripts/*.test.js                              # Guard and discovery tests; no browser
BROWSER_SMOKE_TEST=1 node --test ./scripts/browser-smoke.test.js  # Real headless browser
BROWSER_SMOKE_TEST=1 BROWSER_SMOKE_HEADED=1 node --test ./scripts/browser-smoke.test.js  # Local desktop only
```

The smoke test uses a temporary isolated profile and a loopback test page; it
does not copy the user's profile. Fedora runtime testing is pending. The macOS
tests cover the Linux discovery/display branches, but cannot verify Fedora's
Chromium packaging, libraries, or sandbox. Tests keep the normal `HOME` for macOS
keychain access and isolate the skill's files with `BROWSER_CACHE_DIR` instead.

## SSH and desktop rules

- **Over SSH, always pass `--headless`.** `start.js` exits with an explanatory
  error without it, before contacting a browser, resetting a profile, or launching
  anything. This applies even with X forwarding or a display variable set.
- Detection checks nonempty `SSH_CONNECTION`, `SSH_CLIENT`, and `SSH_TTY`, and
  this user's `IS_SSH_SESSION=1`. In tmux it also checks the current session's
  environment, since a long-lived pane can predate an SSH attachment. If tmux
  inspection fails, visible mode is refused; headless mode still works.
- On Linux without `DISPLAY` or `WAYLAND_DISPLAY`, use `--headless` even outside
  SSH. Display variables allow a local desktop launch; they do not override SSH.
- On a local Mac desktop, tmux alone does not require headless mode. Starting
  without `--headless` opens an ordinary window in the user's desktop session.
  The user can browse, click, type, or authenticate in that window. Coordinate
  with the user before automating the tab again.
- Do not unset SSH variables, alter tmux's environment, use Xvfb, or bypass the
  guard to obtain visible mode remotely. `pick.js` is for a local visible browser
  only and also refuses SSH; use `eval.js` to inspect elements headlessly.

## Start the browser (prefer headless)

```bash
./scripts/start.js --headless            # Recommended: isolated reusable profile
./scripts/start.js --headless --profile  # Headless with a copy of your profile
./scripts/start.js                       # Visible browser window when needed
./scripts/start.js --headless --reset-profile  # Clear cached profile before launch
```

Starts the browser with loopback remote debugging (default port `:9222`). Never expose this unauthenticated control endpoint to the network or forward it without the user's request. **Agents should use `--headless` by default** because it is less disruptive and supports navigation, evaluation, screenshots, emulation, and logging. User extensions are disabled for headless launches; a copied profile still provides its cookies and other browser state, but extension-based features are unavailable. Headed launches continue to load extensions normally. Use headed mode only when a person needs to see or interact with the browser, such as for `pick.js`, manual authentication, or debugging a headless-specific difference.

The start script only reuses a running browser when its profile and launch settings match. Stop the running skill browser before switching between headless and headed mode. Changing the debugging port does **not** isolate the profile: startup refuses to modify a profile already used on another port and preserves Chrome's profile locks.

Profile behavior:
- Default mode uses: `~/.cache/agent-web/browser/fresh-profile`
- `--profile` mode uses: `~/.cache/agent-web/browser/profile-copy`
- The skill **does not attach to your live Chrome profile directly**
- If `:9222` is already used by an unknown instance, start will fail instead of reusing it

If the browser is installed in a non-standard location, set an executable path
or command name. An invalid override fails rather than silently choosing another browser:

```bash
BROWSER_BIN=/path/to/chrome ./scripts/start.js --headless
```

`--profile` copies the selected browser's user-data directory, not necessarily
Chrome's. An explicit source can be set with `BROWSER_PROFILE_SOURCE=/path/to/user-data`.
This is opt-in: do not copy a personal profile without the user's request. Copies
can contain private data, and OS-encrypted cookies are not guaranteed to work on
another machine. The default isolated profile can retain manual logins across
headed and headless launches without copying a personal profile.

If startup fails, inspect `~/.cache/agent-web/browser/launch.log` for browser
output. Missing Linux libraries or display access may need host-specific fixes.

Optional debug endpoint override:

```bash
BROWSER_DEBUG_PORT=9333 ./scripts/start.js --headless
```

For a separate skill session, set `BROWSER_CACHE_DIR=/path/to/cache` and a
separate `BROWSER_DEBUG_PORT` for **every** command, including `stop.js`. The cache
override isolates profiles, launch state, emulation settings, and logs. Do not
change `HOME` to isolate a browser: macOS desktop services, including the
keychain, still need the user's real home directory.

## Stop the browser

```bash
./scripts/stop.js                         # Stop skill Chrome on :9222
BROWSER_DEBUG_PORT=9333 ./scripts/stop.js  # Stop skill Chrome on :9333
./scripts/stop.js --all                   # Stop all skill Chrome instances
```

Works for headless and headed browsers. Only processes using the skill's cached profiles are stopped, not your regular Chrome. Shutdown uses CDP `Browser.close` to flush cookies and other cached state. If CDP is unavailable, it rechecks profile ownership before falling back to `SIGTERM`, with a warning that recent state may not be saved. It never uses `SIGKILL`. Stop before using `--reset-profile`.

To switch to a visible browser on a local desktop (never over SSH):

```bash
./scripts/stop.js
./scripts/start.js
```

## Navigate

```bash
./scripts/nav.js https://example.com
./scripts/nav.js https://example.com --new
```

Navigate current tab or open new tab.

## Device Emulation (Mobile)

```bash
./scripts/emulate.js --list
./scripts/emulate.js iphone-14
./scripts/emulate.js pixel-7 --landscape
./scripts/emulate.js --reset
```

Set an active device emulation preference (viewport, DPR, touch, UA) for browser skill commands. Use `--reset` to clear.

Commands like `nav.js`, `eval.js`, `pick.js`, `dismiss-cookies.js`, and `screenshot.js` automatically apply the active preference.

## Evaluate JavaScript

```bash
./scripts/eval.js 'document.title'
./scripts/eval.js 'document.querySelectorAll("a").length'
./scripts/eval.js 'document.querySelector("button")?.click(); "clicked"'
./scripts/eval.js 'await Promise.resolve(document.title)'
./scripts/eval.js 'JSON.stringify(Array.from(document.querySelectorAll("a")).map(a => ({ text: a.textContent.trim(), href: a.href })).filter(link => !link.href.startsWith("https://")))'
```

Execute JavaScript in the active tab. Input can be an expression or statement list; the console-style completion value is printed and promises/top-level `await` are awaited. Be careful with string escaping, best to use single quotes.

## Screenshot

```bash
./scripts/screenshot.js
./scripts/screenshot.js --full-page
./scripts/screenshot.js --device iphone-14
./scripts/screenshot.js --device pixel-7 --full-page
```

Takes a screenshot and returns a temp file path.

- Default: current viewport
- `--full-page`: captures full document height
- `--device <preset>`: temporary mobile emulation for that screenshot only

## Pick Elements

```bash
./scripts/pick.js "Click the submit button"
```

Interactive element picker. Click to select, Cmd/Ctrl+Click for multi-select, Enter to finish. This requires headed Chrome; launch `start.js` without `--headless`.

## Dismiss Cookie Dialogs

```bash
./scripts/dismiss-cookies.js          # Accept cookies
./scripts/dismiss-cookies.js --reject # Reject cookies (where possible)
```

Automatically dismisses EU cookie consent dialogs.

Run after navigating to a page:
```bash
./scripts/nav.js https://example.com && ./scripts/dismiss-cookies.js
```

## Quick Mobile Debug Flow

```bash
./scripts/start.js --headless
./scripts/nav.js https://example.com
./scripts/emulate.js iphone-14
./scripts/nav.js https://example.com      # reload with mobile UA
./scripts/dismiss-cookies.js
./scripts/screenshot.js --full-page
```

## Background Logging (Console + Errors + Network)

Automatically started by `start.js` and writes JSONL logs to:

```
~/.cache/agent-web/logs/YYYY-MM-DD/<targetId>.jsonl
```

Manually start:
```bash
./scripts/watch.js
```

Tail latest log:
```bash
./scripts/logs-tail.js           # dump current log and exit
./scripts/logs-tail.js --follow  # keep following
```

Summarize network responses:
```bash
./scripts/net-summary.js
```

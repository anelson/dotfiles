---
name: tmux
description: Drive an interactive terminal program through an isolated tmux server. Use for REPLs, debuggers, database consoles, and other TTY-only programs that require keystrokes, prompt detection, or pane capture.
compatibility: Requires tmux and Bash. Python recipes assume uv is available.
---

# Drive interactive programs with tmux

Use tmux when a program requires a real terminal and cannot be controlled reliably through a one-shot shell command. Keep agent-owned sessions off the user's personal tmux server.

The user's login shell normally runs inside a customized tmux server whose windows start at index 1. Agent sessions must instead use a private socket and a clean tmux configuration; their first pane is therefore `:0.0`.

## Start an isolated session

```bash
SOCKET_DIR=${AGENT_TMUX_SOCKET_DIR:-${XDG_RUNTIME_DIR:-${TMPDIR:-/tmp}}/agent-tmux-sockets}
mkdir -p "$SOCKET_DIR"
SOCKET="$SOCKET_DIR/agent.sock"
SESSION=agent-python  # short slug; avoid spaces

tmux -f /dev/null -S "$SOCKET" new-session -d -s "$SESSION" -n shell
```

Use the same `-S "$SOCKET"` argument for every later command. Do not use the default server, and do not load `~/.tmux.conf`; that would mix automation with the user's long-lived sessions and plugins.

Immediately after starting a session, give the user copy-and-paste monitoring commands. Repeat them in the final report:

```text
Capture the current output:
  tmux -S "$SOCKET" capture-pane -p -J -t agent-python:0.0 -S -200

Attach from a separate terminal:
  tmux -S "$SOCKET" attach-session -t agent-python
```

The user is often already inside tmux. A nested attachment is possible with `TMUX=` before the attach command, but pane capture is less confusing because both servers use `C-a` as their prefix.

## Send input safely

Send text literally, then send Enter separately. This avoids shell interpolation and accidental key-name parsing:

```bash
tmux -S "$SOCKET" send-keys -t "$SESSION":0.0 -l -- 'command --with "$literal" text'
tmux -S "$SOCKET" send-keys -t "$SESSION":0.0 Enter
```

Send terminal keys by name:

```bash
tmux -S "$SOCKET" send-keys -t "$SESSION":0.0 C-c
tmux -S "$SOCKET" send-keys -t "$SESSION":0.0 C-d
tmux -S "$SOCKET" send-keys -t "$SESSION":0.0 Escape
```

Never combine untrusted text into a shell command. If the program accepts a file or standard input, prefer that interface to typing a large payload into the pane.

## Read output and wait for prompts

Capture joined wrapped lines so output is easier to inspect:

```bash
tmux -S "$SOCKET" capture-pane -p -J -t "$SESSION":0.0 -S -200
```

Use the bundled helper rather than fixed sleeps when one action depends on a prompt:

```bash
scripts/wait-for-text.sh \
  -S "$SOCKET" \
  -t "$SESSION":0.0 \
  -p '^>>>' \
  -T 15 \
  -l 4000
```

The helper polls until it sees a regular expression. Add `-F` for a fixed string. On timeout, it prints the captured pane to standard error.

List one socket or scan all agent-owned sockets:

```bash
scripts/find-sessions.sh -S "$SOCKET"
scripts/find-sessions.sh --all
```

Resolve `scripts/...` relative to this skill's directory.

## Common programs

### Python

Use uv and the basic CPython REPL. The basic REPL responds predictably to sent keys:

```bash
tmux -S "$SOCKET" send-keys -t "$SESSION":0.0 -l -- \
  'PYTHON_BASIC_REPL=1 uv run python -q'
tmux -S "$SOCKET" send-keys -t "$SESSION":0.0 Enter
```

Wait for `^>>>` before sending code. Keep the current project active so its uv environment and dependencies remain available.

### Debuggers

Use LLDB by default unless the project or user requires GDB. Disable pagination before collecting long backtraces. Interrupt a running inferior with `C-c`, then issue commands such as `bt`, `frame variable`, or `register read` one at a time.

### Other TTY programs

The same pattern works for `ipdb`, `psql`, `mysql`, and similar programs: start the process, wait for its prompt, send literal input, capture the result, and keep enough scrollback for diagnosis.

## Clean up

Kill a completed session:

```bash
tmux -S "$SOCKET" kill-session -t "$SESSION"
```

Kill the private server only when no other agent-owned session on that socket is needed:

```bash
tmux -S "$SOCKET" kill-server
```

Do not leave a session running unless the user needs the process to continue. If it remains, report the socket, session, pane target, and monitoring command.

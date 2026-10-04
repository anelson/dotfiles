---
name: ssh
description: Use the user's SSH-agent authentication environment correctly, especially inside long-lived tmux sessions and for Git operations over SSH. Use this skill before diagnosing SSH key failures, refreshing SSH_AUTH_SOCK, testing agent identities, connecting to a remote system over SSH, or running SSH-backed Git commands for the user.
---

# SSH Authentication

Unless explicitly stated otherwise (or subject to exceptions below), I always use SSH Agent authentication. I do not
typically bother to place private keys in ~/.ssh, and the lack thereof is not ever the reason for an authentication
problem.

- On macOS, SSH uses the 1Password agent when its socket exists.
- Remote sessions commonly receive a forwarded agent socket. Each SSH login can create a new socket path.
- A long-running tmux server updates its stored `SSH_AUTH_SOCK` when a client attaches, but shells in existing panes can retain an older path. A sign that this is the case is the `$TMUX` env var is set.
- On Linux, running a local session (meaning not connected over SSH), I may use the GPG agent to store the private key
  on a Yubikey, or I may use a local private key in ~/.ssh, but this is the most uncommon configuration and should not
  be assumed absent evidence.

Treat a stale socket path and a denied or unapproved signing request as different problems.

## Test SSH agent function

If the SSH agent configuration is correct, `ssh-add -L` will list multiple available private keys. When only the result
matters, redirect the key material and inspect the exit status instead of copying public keys into chat or logs:

```sh
ssh-add -L >/dev/null
```

If this doesn't produce any output, then the SSH auth sock is not configured properly.

If this does list keys, but SSH auth is still failing, the most likely reason is that I am AFK and did not explicitly
approve the SSH auth request pop-up on my local system. In that case you must stop and report this, and await my
action. It's also possible that the remote system doesn't trust any of my SSH keys; this is less common, but should be
evident in the SSH failure message if it's happening.

## Refresh the socket from tmux

When running in an interactive shell under tmux, I use `eval $(tmux showenv -s SSH_AUTH_SOCK)` to force the SSH auth
sock to be set correctly. This is done automatically when a new session starts, but if my SSH connection drops and I
subsequently reconnect, the auth sock path will be different, so any shell environments from before the reconnect will
point to the wrong auth socket, and `ssh-add -L` will not find any keys.

In that case, get the current socket from the tmux server rather than trusting the shell's inherited value:

```sh
tmux show-environment -s SSH_AUTH_SOCK
```

Import that value into the current shell before using SSH:

```sh
eval "$(tmux showenv -s SSH_AUTH_SOCK)"
```

Then confirm that the variable names a socket

```sh
test -S "$SSH_AUTH_SOCK"
```

If tmux has no `SSH_AUTH_SOCK`, or if tmux has an SSH auth sock but it's not a valid socket, it's likely that my SSH
connection has dropped and I have not reconnected, thus there is no viable agent auth pathway. In that case you must
stop and report this fact.

## Running SSH

The user's interactive remote-shell configuration normally aliases `ssh` through `~/.local/bin/tmux-ssh` and gives Git a matching `GIT_SSH_COMMAND`. Agent and noninteractive shells may not load those aliases, so refresh the current shell explicitly. For a single SSH command, the wrapper is also available:

```sh
"$HOME/.local/bin/tmux-ssh" host command
```

For a single Git command that uses SSH:

```sh
GIT_SSH_COMMAND="$HOME/.local/bin/tmux-ssh" git <arguments>
```

## Handle approval while the user is away

The agent can require the user to approve an authentication operation, unlock 1Password, or touch a YubiKey. Consequently, SSH authentication can fail or time out even when `SSH_AUTH_SOCK` is current and `ssh-add -L` succeeds.

If the socket is valid but an SSH or Git authentication attempt is denied, times out, or waits for approval:

1. Do not treat the result as proof that the key, account, remote URL, or server configuration is wrong.
2. Do not retry in a loop; repeated attempts can create expiring approval prompts and noise.
3. Tell the user that the local agent appears reachable but the authentication operation may require their presence and approval.
4. Ask the user to return, unlock or authorize the agent, and touch the hardware token if prompted.
5. Wait until the user confirms they are present, then rerun `ssh-add -L` and retry the original SSH or Git operation once.
6. If the retry still fails while the user is present, capture the exact SSH error and investigate it as a separate configuration or authorization problem.

Do not work around an absent user by changing remotes to HTTPS, copying private keys, disabling agent use, weakening host checks, restarting the user's agent, or modifying `~/.ssh/config` unless the user explicitly asks for that change.

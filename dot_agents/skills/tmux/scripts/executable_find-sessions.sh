#!/usr/bin/env bash
# Adapted and modified from mitsuhiko/agent-stuff (Apache-2.0).
set -euo pipefail

usage() {
  cat <<'USAGE'
Usage: find-sessions.sh [-L socket-name | -S socket-path | --all] [-q pattern]

List agent-owned tmux sessions. With no socket option, use
$AGENT_TMUX_SOCKET_DIR/agent.sock (or the platform runtime-directory default).

Options:
  -L, --socket       tmux socket name (passed to tmux -L)
  -S, --socket-path  tmux socket path (passed to tmux -S)
  -A, --all          scan sockets under AGENT_TMUX_SOCKET_DIR
  -q, --query        case-insensitive substring in the session name
  -h, --help         show this help
USAGE
}

socket_name=""
socket_path=""
query=""
scan_all=false
socket_dir="${AGENT_TMUX_SOCKET_DIR:-${XDG_RUNTIME_DIR:-${TMPDIR:-/tmp}}/agent-tmux-sockets}"

while [[ $# -gt 0 ]]; do
  case "$1" in
    -L|--socket)
      [[ $# -ge 2 ]] || { echo "Missing value for $1" >&2; exit 2; }
      socket_name=$2
      shift 2
      ;;
    -S|--socket-path)
      [[ $# -ge 2 ]] || { echo "Missing value for $1" >&2; exit 2; }
      socket_path=$2
      shift 2
      ;;
    -A|--all)
      scan_all=true
      shift
      ;;
    -q|--query)
      [[ $# -ge 2 ]] || { echo "Missing value for $1" >&2; exit 2; }
      query=$2
      shift 2
      ;;
    -h|--help)
      usage
      exit 0
      ;;
    *)
      echo "Unknown option: $1" >&2
      usage >&2
      exit 2
      ;;
  esac
done

if [[ $scan_all == true && ( -n $socket_name || -n $socket_path ) ]]; then
  echo "Cannot combine --all with -L or -S" >&2
  exit 2
fi

if [[ -n $socket_name && -n $socket_path ]]; then
  echo "Use either -L or -S, not both" >&2
  exit 2
fi

if ! command -v tmux >/dev/null 2>&1; then
  echo "tmux not found in PATH" >&2
  exit 127
fi

list_sessions() {
  local label=$1
  shift
  local -a tmux_cmd=(tmux "$@")
  local sessions

  if ! sessions=$("${tmux_cmd[@]}" list-sessions \
      -F $'#{session_name}\t#{session_attached}\t#{t:session_created}' \
      2>/dev/null); then
    echo "No tmux server found on $label" >&2
    return 1
  fi

  if [[ -n $query ]]; then
    sessions=$(printf '%s\n' "$sessions" | grep -iF -- "$query" || true)
  fi

  if [[ -z $sessions ]]; then
    echo "No matching sessions found on $label"
    return 0
  fi

  echo "Sessions on $label:"
  while IFS=$'\t' read -r name attached created; do
    [[ -n $name ]] || continue
    local attached_label=detached
    [[ $attached == 1 ]] && attached_label=attached
    printf '  - %s (%s, started %s)\n' "$name" "$attached_label" "$created"
  done <<<"$sessions"
}

if [[ $scan_all == true ]]; then
  if [[ ! -d $socket_dir ]]; then
    echo "Socket directory not found: $socket_dir" >&2
    exit 1
  fi

  shopt -s nullglob
  sockets=("$socket_dir"/*)
  shopt -u nullglob

  found=false
  exit_code=0
  for socket in "${sockets[@]}"; do
    [[ -S $socket ]] || continue
    found=true
    list_sessions "socket path '$socket'" -S "$socket" || exit_code=$?
  done

  if [[ $found == false ]]; then
    echo "No tmux sockets found under $socket_dir" >&2
    exit 1
  fi
  exit "$exit_code"
fi

if [[ -n $socket_name ]]; then
  list_sessions "socket name '$socket_name'" -L "$socket_name"
else
  socket_path=${socket_path:-"$socket_dir/agent.sock"}
  list_sessions "socket path '$socket_path'" -S "$socket_path"
fi

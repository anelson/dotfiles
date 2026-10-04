#!/usr/bin/env bash
# Adapted and modified from mitsuhiko/agent-stuff (Apache-2.0).
set -euo pipefail

usage() {
  cat <<'USAGE'
Usage: wait-for-text.sh -t target -p pattern [options]

Poll a tmux pane until its captured output contains a pattern.

Options:
  -L, --socket       tmux socket name (passed to tmux -L)
  -S, --socket-path  tmux socket path (passed to tmux -S)
  -t, --target       pane target, such as session:0.0 (required)
  -p, --pattern      extended regular expression to find (required)
  -F, --fixed        treat the pattern as a fixed string
  -T, --timeout      whole seconds to wait (default: 15)
  -i, --interval     polling interval accepted by sleep (default: 0.5)
  -l, --lines        pane history lines to inspect (default: 1000)
  -h, --help         show this help
USAGE
}

socket_name=""
socket_path=""
target=""
pattern=""
fixed=false
timeout=15
interval=0.5
lines=1000

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
    -t|--target)
      [[ $# -ge 2 ]] || { echo "Missing value for $1" >&2; exit 2; }
      target=$2
      shift 2
      ;;
    -p|--pattern)
      [[ $# -ge 2 ]] || { echo "Missing value for $1" >&2; exit 2; }
      pattern=$2
      shift 2
      ;;
    -F|--fixed)
      fixed=true
      shift
      ;;
    -T|--timeout)
      [[ $# -ge 2 ]] || { echo "Missing value for $1" >&2; exit 2; }
      timeout=$2
      shift 2
      ;;
    -i|--interval)
      [[ $# -ge 2 ]] || { echo "Missing value for $1" >&2; exit 2; }
      interval=$2
      shift 2
      ;;
    -l|--lines)
      [[ $# -ge 2 ]] || { echo "Missing value for $1" >&2; exit 2; }
      lines=$2
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

if [[ -z $target || -z $pattern ]]; then
  echo "Both --target and --pattern are required" >&2
  usage >&2
  exit 2
fi

if [[ -n $socket_name && -n $socket_path ]]; then
  echo "Use either -L or -S, not both" >&2
  exit 2
fi

if ! [[ $timeout =~ ^[0-9]+$ ]]; then
  echo "timeout must be a whole number of seconds" >&2
  exit 2
fi

if ! [[ $lines =~ ^[1-9][0-9]*$ ]]; then
  echo "lines must be a positive integer" >&2
  exit 2
fi

if ! command -v tmux >/dev/null 2>&1; then
  echo "tmux not found in PATH" >&2
  exit 127
fi

if ! [[ $interval =~ ^[0-9]+([.][0-9]+)?$ ]] || [[ $interval =~ ^0+([.]0+)?$ ]]; then
  echo "interval must be a positive number of seconds" >&2
  exit 2
fi

start_epoch=$(date +%s)
deadline=$((start_epoch + timeout))

tmux_cmd=(tmux)
if [[ -n $socket_name ]]; then
  tmux_cmd+=(-L "$socket_name")
elif [[ -n $socket_path ]]; then
  tmux_cmd+=(-S "$socket_path")
fi

grep_args=(-E)
[[ $fixed == true ]] && grep_args=(-F)

while true; do
  pane_text=$("${tmux_cmd[@]}" capture-pane -p -J -t "$target" -S "-$lines" 2>/dev/null || true)

  if printf '%s\n' "$pane_text" | grep "${grep_args[@]}" -- "$pattern" >/dev/null 2>&1; then
    exit 0
  fi

  now=$(date +%s)
  if (( now >= deadline )); then
    echo "Timed out after ${timeout}s waiting for pattern: $pattern" >&2
    echo "Last ${lines} lines from $target:" >&2
    printf '%s\n' "$pane_text" >&2
    exit 1
  fi

  sleep "$interval"
done

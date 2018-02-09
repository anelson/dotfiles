#!/usr/bin/env sh

# Terminate already running bar instances
killall -q polybar

# Wait until the processes have been shut down
while pgrep -u $UID -x polybar >/dev/null; do sleep 1; done

# Launch polybar on all displays
active_monitors=( $(xrandr | grep " connected" | cut -d ' ' -f1) )

for mon in "${active_monitors[@]}"; do
  MONITOR="$mon" polybar top &
done

echo "Bars launched..."


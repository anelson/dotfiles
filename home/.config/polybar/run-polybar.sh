#!/usr/bin/env sh

# Terminate already running bar instances
killall -q polybar

# Wait until the processes have been shut down
while pgrep -u $UID -x polybar >/dev/null; do sleep 1; done

# Launch polybar on all displays
active_monitors=( $(xrandr | grep " connected" | cut -d ' ' -f1) )

tray_position=
for mon in "${active_monitors[@]}"; do
  MONITOR="$mon" TRAY_POSITION="$tray_position" polybar top &
  # The tray should appear only on the first monitor, so set the tray position to none for all subsequent monitors
  tray_position="none"
done

echo "Bars launched..."


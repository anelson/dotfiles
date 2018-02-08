#!/bin/sh
#
# Kill compton if it's running and start it agian

killall -q compton

# Wait until the processes have been shut down
while pgrep -u $UID -x polybar >/dev/null; do sleep 1; done

compton -b


#!/bin/sh
#
# Configures custom key bindings using xmodmap.
#
# Note that for stupid timing reasons, invoking `xmodmap ~/.Xmodmap` in i3's
# config file doesn't work right.  If any key is pressed (which it often is if
# i3 is being reloaded with the reload sequence) then xmodmap fails to load the
# new bindings.  Yes that seems dumb to me too

# This pains me but it seems to be required to wait a few seconds so there are no keys pressed
# in order for these settings to work.  I do not understand why but this seems to be the consensus
# solution online
sleep 5

# Disable capslock
xmodmap -e "clear lock"

# Map capslock to escape
xmodmap -e "keycode 0x42 = Escape"


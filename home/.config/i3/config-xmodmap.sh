#!/bin/sh
#
# Configures custom key bindings using xmodmap.
#
# Note that for stupid timing reasons, invoking `xmodmap ~/.Xmodmap` in i3's
# config file doesn't work right.  If any key is pressed (which it often is if
# i3 is being reloaded with the reload sequence) then xmodmap fails to load the
# new bindings.  Yes that seems dumb to me too

# Disable capslock
xmodmap -e "clear lock"

# Map capslock to escape
xmodmap -e "keycode 0x42 = Escape"


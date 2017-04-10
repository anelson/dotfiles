#!/bin/sh

# If gsettings is present, apply the Gnome settings I like
test -z "$DBUS_SESSION_BUS_ADDRESS" && return
test -x /usr/bin/gsettings || return


# Force Gnome to use my preferred monospace font
gsettings set org.gnome.desktop.interface monospace-font-name "Source Code Pro 12"

# Don't let Nautilus show a desktop window, which breaks it in i3
gsettings set org.gnome.desktop.background show-desktop-icons false


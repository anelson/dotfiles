#!/bin/sh
#
# Generates i3 config directives to ignore the "floating" role Chromium for some reason sets
# on desktop applications created using the "Add to desktop" feature
DESKTOP_DIR="${XDG_DESKTOP_DIR:-$HOME/Desktop}"
for desktopfile in "$DESKTOP_DIR"/*.desktop; do
    name=$(grep Name "$desktopfile" | cut -f2 -d '=')
    class=$(grep StartupWMClass "$desktopfile" | cut -f2 -d '=')
    if [[ -n "$class" ]]; then
        # Instruct i3 that this window class should not be floating, even though
        # Chromium sets it window type to popup
        echo "for_window [instance=\"$class\"] floating disable #$name"
    fi
done


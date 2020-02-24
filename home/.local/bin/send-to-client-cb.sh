#!/usr/bin/bash
#
# Shitty hack that uses OSC 52 terminal escape codes to push input to the clipboard of the client termina.
#
# This shitty workaround brought to you by this bug in Alacritty:
# https://github.com/alacritty/alacritty/pull/3194
#
# Basically only about 700 characters can be put onto the clipboard as of 0.4.1.  A fix was merged just a few days after 0.4.1
# was released, so one can hope the next dot release will include it
#
# This script doesn't work at all well with binary data or with non-ascii characters.  It's just a hack really
contents=`cat`
#echo "Contents: $contents"

contents_b64=$(printf $contents | base64)
#echo "Contents(base64): $contents_b64"

echo "Copying to client clipboard"
printf "\e]52;c;$(printf $contents_b64)\a"


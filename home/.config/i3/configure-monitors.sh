#!/bin/bash
#
# Meant to be called from a udev rule, or in emergencies by hand
#
# Assesses the current state of attached monitors and decides what configuration
# to deploy.
#
# This is customized to my specific environment.  If there are two HiDPI external displays connected,
# I want both of those activated and the built-in laptop display deactivated.
#
# If there are no external displays, I want all workspaces displayed on the built-in screen
#
# If there is just one external display, I want to extend the screen to that display and keep using the 
# built-in display
#
# This script started out just wrapping 'mons', but then I had problems where mons would fail sometimes to
# work properly due to errors reported from xrandr, so I modified it to call xrandr directly, but now I seem to get
# errors as well.  This is at the same time that docking and undocking from my TB16 dock is unreliable
# so it's entirely possible the mons approach was perfectly adequate after all
BUILTIN_MONITOR_NAME="eDP1" # this seems to be pretty consistent
BUILTIN_MONITOR_DPI="240" #basically a 2.5x scaling factor when using the built-in monitor
EXTERNAL_MONITOR_DPI="96" #my external 4K HiDPI monitors are big enough they don't need such a big scale factor

# the mons script assigns monitors numbers, from what I can tell it's based on their outpt order
# in xrandr.  But they're not contiguous integers.  on my system the built-in display is 0, 
# one displayport monitor is 5, and the other is 6.
#
# this function takes as a parameter the ordinal number of the monitor (starting from 1)
# and returns the number used to identify this display by mons.
#
# This works just like the abov get_monitor_number_from_orginal except
# is returns the monitors name (eg "eDP1") instead 
get_monitor_name_from_ordinal() {
    local ordinal=$1;

    # There's some output before the list of monitors, skip right to the list
    # after that mons uses multiple spaces to pad the list of names, so skip over that
    (grep '^[0-9]' <<< "$mons_output" | sed "${ordinal}q;d"  | tr --squeeze-repeats ' ' |  cut  -d ' ' -f2)
}

xrandr_out=$(xrandr)

# make arrays with the names of ALL monitors, and of just those that are connected
all_monitors=( $(echo "$xrandr_out" | grep connect | cut -f1 -d ' ') )
connected_monitors=( $(echo "$xrandr_out" | grep " connect" | cut -f1 -d ' ') )

echo "Found ${#connected_monitors[@]} connected monitors:"
for mon in "${connected_monitors[@]}"; do
    echo "    $mon"
done

# just assume the built-in is always the first monitor in the output
builtin_name="${connected_monitors[0]}"
monitor1_name="${connected_monitors[1]}"
monitor2_name="${connected_monitors[2]}"
echo "Built in: $builtin_name"
echo "External 1: $monitor1_name"
echo "External 2: $monitor2_name"

if [[ "$builtin_name" -ne "$BUILTIN_MONITOR_NAME" ]]; then
    echo "ERROR: expecting the first monitor to be $BUILTIN_MONITOR_NAME!"
    exit -1;
fi

# start with the xrandr auto config since it seems to get confused easily
xrandr --auto --dpi "$BUILTIN_MONITOR_DPI"

if [[ -z "$monitor1_name" && -z "$monitor2_name" ]]; then
    # No external monitors configured
    # Use only the built-in monitor
    echo "Using only built in display"
    xrandr --verbose --output "$builtin_name" --primary --auto --dpi "$BUILTIN_MONITOR_DPI" # I think maybe mons is a no-op when there's only one monitor
    #mons --primary "$builtin_name" --dpi "$BUILTIN_MONITOR_DPI"
elif [[ -z "$monitor2_name" ]]; then
    # There is one external monitor connected.  This is a common scenario with projectors
    # Extend the display to include the external
    # Note that we keep the DPI set to the internal display's DPI, since we assume this
    # external monitor is used for some secondary purpose like a presentation
    echo "Extending the built-in display to include display $monitor1_name"
    #mons -S "$builtin_name,$monitor1_name:R" --primary "$builtin_name" --dpi "$BUILTIN_MONITOR_DPI"
    xrandr --verbose --output $builtin_name --auto --primary 
    xrandr --verbose --output $monitor1_name --auto --right-of $builtin_name 
    xrandr --verbose --dpi $BUILTIN_MONITOR_DPI
else
    # Two monitors connected
    #
    # Disable the built-in monitor, and enable both of the external ones assuming the first
    # one in the sort order is positioned to the left of the second one.
    # NOTE: At this point I make a very environmentaly specific assumption, that the only time 
    # I connect two monitors at once, they are my 4k HiDPI monitors at home.  If regular HD
    # monitors are used this will result in a bad time
    echo "Enabling both external displays and disabling internal display"
    #mons -S "$monitor1_name,$monitor2_name:R" --primary "$builtin_name" --dpi "$EXTERNAL_MONITOR_DPI"
    xrandr --verbose --output $builtin_name --off 
    xrandr --verbose --output $monitor2_name --mode "3840x2160"   --pos 0x0
    xrandr --verbose --output $monitor1_name --mode "3840x2160"  --right-of $monitor2_name
    xrandr --verbose --dpi $EXTERNAL_MONITOR_DPI

fi




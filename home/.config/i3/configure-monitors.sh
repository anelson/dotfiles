#!/bin/sh
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
# On my system right now, 
#   get_monitor_number(1) = 0 (built in display)
#   get_monitor_number(2) = 5 (left external monitor)
#   get_monitor_number(3) = 6 ( right external monitor)
#   get_monitor_number(anything more than 3) = error
get_monitor_number_from_ordinal() {
    local ordinal=$1;

    # There's some output before the list of monitors, skip right to the list
    (grep '^[0-9]:' <<< "$mons_output" | sed "${ordinal}q;d" | cut -f1 -d ':');
}

# This works just like the abov get_monitor_number_from_orginal except
# is returns the monitors name (eg "eDP1") instead 
get_monitor_name_from_ordinal() {
    local ordinal=$1;

    # There's some output before the list of monitors, skip right to the list
    # after that mons uses multiple spaces to pad the list of names, so skip over that
    (grep '^[0-9]' <<< "$mons_output" | sed "${ordinal}q;d"  | tr --squeeze-repeats ' ' |  cut  -d ' ' -f2)
}


get_monitor_number_from_name() {
    local name = $1;
    (grep "$name" <<< "$mons_output" | cut -f1 -d ':');
}

mons_output=$(mons)
monitor_count=$(grep Monitors <<< "$mons_output" | cut -f2 -d ':')

echo "${mons_output}"

echo "detected monitor count $monitor_count"

# just assume the built-in is always the first monitor in the output
builtin_number=$(get_monitor_number_from_ordinal 1)
builtin_name=$(get_monitor_name_from_ordinal 1)
monitor1_number=$(get_monitor_number_from_ordinal 2)
monitor1_name=$(get_monitor_name_from_ordinal 2)
monitor2_number=$(get_monitor_number_from_ordinal 3)
monitor2_name=$(get_monitor_name_from_ordinal 3)

echo "Built in: $builtin_number - $builtin_name"
echo "External 1: $monitor1_number - $monitor1_name"
echo "External 2: $monitor2_number - $monitor2_name"

if [[ "$(get_monitor_name_from_ordinal 1)" -ne "$BUILTIN_MONITOR_NAME" ]]; then
    echo "ERROR: expecting the first monitor to be $BUILTIN_MONITOR_NAME!"
    exit -1;
fi

if [[ -z "$builtin_number" ]]; then 
    echo "ERROR! No built-in display found!"
    xrandr --auto
    exit -1
fi

if [[ -z "$monitor1_number" && -z "$monitor2_number" ]]; then
    # No external monitors configured
    # Use only the built-in monitor
    echo "Using only built in display"
    xrandr --output "$builtin_name" --primary --auto --dpi "$BUILTIN_MONITOR_DPI" # I think maybe mons is a no-op when there's only one monitor
    #mons --primary "$builtin_name" --dpi "$BUILTIN_MONITOR_DPI"
elif [[ -z "$monitor2_number" ]]; then
    # There is one external monitor connected.  This is a common scenario with projectors
    # Extend the display to include the external
    # Note that we keep the DPI set to the internal display's DPI, since we assume this
    # external monitor is used for some secondary purpose like a presentation
    echo "Extending the built-in display to include display $monitor1_number"
    #mons -S "$builtin_number,$monitor1_number:R" --primary "$builtin_name" --dpi "$BUILTIN_MONITOR_DPI"
    xrandr --output $builtin_name --auto --primary \
        --output $monitor1_name --auto --right-of $builtin_name \
        --dpi $BUILTIN_MONITOR_DPI
else
    # Two monitors connected
    #
    # Disable the built-in monitor, and enable both of the external ones assuming the first
    # one in the sort order is positioned to the left of the second one.
    # NOTE: At this point I make a very environmentaly specific assumption, that the only time 
    # I connect two monitors at once, they are my 4k HiDPI monitors at home.  If regular HD
    # monitors are used this will result in a bad time
    echo "Enabling both external displays and disabling internal display"
    #mons -S "$monitor1_number,$monitor2_number:R" --primary "$builtin_name" --dpi "$EXTERNAL_MONITOR_DPI"
    xrandr --output $builtin_name --off --output $monitor1_name --auto --output $monitor2_name --auto --right-of $monitor1_name --dpi $EXTERNAL_MONITOR_DPI

fi




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
BUILTIN_MONITOR_NAME="eDP" # this seems to be pretty consistent
BUILTIN_MONITOR_DPI="192" #basically a 2x scaling factor when using the built-in monitor
EXTERNAL_MONITOR_HIDPI="144" #my external 4K HiDPI monitors are big enough they don't need such a big scale factor. this is 1.5x
EXTERNAL_MONITOR_LOWDPI="96" #external 1080p HD monitors have pretty low resolution

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

get_monitor_resolutions() {
    local name=$1;
    # Filter only for the output concerned with this specific monitor, and skip
    # the first line which is a header and lists the current resolution
    (xrandr | \
      awk -v monitor="^$name connected" '/connected/ {p = 0} \
        $0 ~ monitor {p = 1} \
        p' | \
      sed -e 1d
    )
}

get_monitor_current_resolution() {
    local name=$1;

    local resolutions=$(get_monitor_resolutions $name)

    # Filter the resolution lines that contain a WIDTHxHEIGHT  REFRESH +
    # where the "+" indicates the current resolution
    (grep -o '[0-9][0-9]*x[0-9][0-9]*\W*[0-9][0-9]*\.[0-9][0-9]*.*+' <<< "$resolutions")
}

xrandr_out=$(xrandr)

# make arrays with the names of ALL monitors, and of just those that are connected
all_monitors=( $(echo "$xrandr_out" | grep connect | cut -f1 -d ' ') )
connected_monitors=( $(echo "$xrandr_out" | grep " connect" | cut -f1 -d ' ') )

echo "Found ${#connected_monitors[@]} connected monitors:"
for mon in "${connected_monitors[@]}"; do
    echo "    $mon"
    # NOTE: As of now, this logic around getiing the current resolution isn't needed because I figured out why the
    # maximum resolution wasn't being reported propertly (hint: DP works better than HDMI)
    # However, I'm leaving this code in here in case I need to make this script smarter in the future
    resolutions=$(get_monitor_current_resolution "$mon")
    echo "      Current resolution: $resolutions"
done

# just assume the built-in is always the first monitor in the output
builtin_name="${connected_monitors[0]}"
monitor1_name="${connected_monitors[1]}"
monitor2_name="${connected_monitors[2]}"
echo "Built in: $builtin_name"
echo "External 1: $monitor1_name"
echo "External 2: $monitor2_name"

# builtin is a concept for a laptop
# if it's missing it means this is a desktop
if [[ "$builtin_name" != "$BUILTIN_MONITOR_NAME"* ]]; then
    echo "WARNING: expecting the first monitor to start with prefix $BUILTIN_MONITOR_NAME!  Assuming this is a dekstop system"
    monitor2_name="${monitor1_name}"
    monitor1_name="${builtin_name}"

    if [[ -z "$monitor2_name" ]]; then
        # there's only one monitor connected.  We don't need to config that.  xrandr will have activated it
        echo "Single monitor ${monitor1_name} detected; no further configuration needed"
    else
        # Two monitors connected
        echo "Dual monitors detected; configuring ${monitor2_name} to be left of ${monitor1_name}"
        xrandr --verbose --output $monitor2_name --left-of $monitor1_name
    fi
else
    # start with the xrandr auto config since it seems to get confused easily
    echo "Resetting xrandr config using --auto and DPI $BUILTIN_MONITOR_DPI"
    xrandr --auto --dpi "$BUILTIN_MONITOR_DPI"

    if [[ -z "$monitor1_name" && -z "$monitor2_name" ]]; then
        # No external monitors configured
        # Use only the built-in monitor
        echo "Using only built in display"
        xrandr --verbose --output "$builtin_name" --primary --auto --dpi "$BUILTIN_MONITOR_DPI" # I think maybe mons is a no-op when there's only one monitor
        #mons --primary "$builtin_name" --dpi "$BUILTIN_MONITOR_DPI"
    elif [[ -z "$monitor2_name" ]]; then
        # There is one external monitor connected.  This is a common scenario with projectors
        # It's unlikely that this one external monitor is 4K, and a mix of 4K and 1080p displays is a disaster
        # Thus, disable the on-board display and use only the external
        echo "Disabling built-in display and using single external display $monitor1_name"
        #mons -S "$builtin_name,$monitor1_name:R" --primary "$builtin_name" --dpi "$BUILTIN_MONITOR_DPI"
        xrandr --verbose --output $builtin_name --off
        xrandr --verbose --dpi $EXTERNAL_MONITOR_HIDPI
        xrandr --verbose --output $monitor1_name --auto --primary --dpi $EXTERNAL_MONITOR_HIDPI
        # xrandr --verbose --output $builtin_name --auto --primary
        #xrandr --verbose --output $monitor1_name --auto --right-of $builtin_name
        #xrandr --verbose --dpi $BUILTIN_MONITOR_DPI
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
        xrandr --verbose --dpi $EXTERNAL_MONITOR_HIDPI

    fi
fi


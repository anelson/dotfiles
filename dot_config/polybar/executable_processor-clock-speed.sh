#!/bin/bash

# Looks at the current clock speed of all the cores, 
# and prints the highest 
#
# Enumerate the 'sys filesystem to get all of the 
# 'scaling_cur_freq' files, read them into an array
# and somehow compute the max
frequency_files=$(find /sys/devices/system/cpu/cpufreq -name scaling_cur_freq)
cpu_frequencies=$(cat $frequency_files)
max_frequency=$(echo "$cpu_frequencies" | sort -nr | head -n1)

# the frequencies are always reported in kilohertz
# I want to pretty-print them
max_ghz=$(echo "$max_frequency / 1024 / 1024" | bc -l)
printf "%0.2f" $max_ghz



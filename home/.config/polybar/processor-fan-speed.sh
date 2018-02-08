#!/bin/sh
# Outputs the processor's fan speed in RPM
sensors | sed -n -E "s/Processor Fan:[[:blank:]]*([[:digit:]]+) RPM/\1/p"


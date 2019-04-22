#!/usr/bin/env bash
#
#
# Sometimes gpg-agent gets "stuck", and stops handling SSH auth with the yubikey
# this script terminates it, and reinitializes it
#
# Use it on the client system, laptop or desktop, where the Yubikey is physically located
#
# NOTE: I think the `gpg-reset` script is better, experiment next time the agent hangs and delete the one that doesn't work
echo Resetting GPG agent

echo Killing any running agent processes
killall gpg-agent

echo Restarting the agent and updating startup TTY
echo "UPDATESTARTUPTTY\nBYE\nQUIT" | gpg-connect-agent

echo GPG agent reset


#!/bin/bash
# tip: Make this file a shortcut, e.g. Ctrl-Alt-X

# https://stackoverflow.com/a/15139734
PID=$(pgrep -f "run_both.bash")
if [ $? -eq 0 ]; then
    echo Found PID, killing.
    PGID=$(ps -o pgid= $PID | grep -o '[0-9]*') 
    kill -INT -"$PGID"
else
    echo No PID found, doing nothing.
fi

# notify that we finished running the kill command
blink1-tool --magenta --glimmer=2
#!/bin/bash
# tip: Make this file a shortcut, e.g. Ctrl-Alt-X

# https://stackoverflow.com/a/15139734
# PID=$(pgrep -f "run_both.bash")
# if [ $? -eq 0 ]; then
#     echo Found PID, killing.
#     PGID=$(ps -o pgid= $PID | grep -o '[0-9]*') 
#     kill -INT -"$PGID"
# else
#     echo No PID found, doing nothing.
# fi


echo "pkill gst-launch-1.0"
pkill -f -INT "gst-launch-1.0"
echo "kill node"
rosnode kill "data_collect" || echo "/data_collect rosbag record node not running, nothing to kill"
sleep 1
rosnode kill "flir_nodelet" || echo "/flir_nodelet node not running, nothing to kill"
sleep 1
rosnode kill "flir_nodelet_manager" || echo "/flir_nodelet_manager node not running, nothing to kill"
sleep 2
echo "pkill heartbeat"
pkill -f "blink_heartbeat.bash"
pkill -f "blink_heartbeat.bash"

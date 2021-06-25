#!/bin/bash
# run me at startup

script_full_path=$(dirname "$0")

# check if DJI SDK started; if not, start it.
if rosnode list | grep -q "/dji_sdk"; then
    echo "DJI SDK already started"
else
    echo "Starting DJI SDK"
    source /home/wildfire/Development/dji_sample_ws/devel/setup.bash
    nohup roslaunch dji_sdk sdk.launch &
    sleep 4
fi

# let our last_status set to 1
# dji uses 1-5: GROUND, TAKEOFF, FLYING, LANDING, LANDING COMPLETE
# FLYING goes into effect when the M100 is "armed", i.e. both joysticks down center. so arming should start recording
ON_GROUND=1
FLYING=3

prev_state="$ON_GROUND"
standby=true

echo "Monitoring state..."
while true; do

    # poll /dji_sdk/flight_status. 
    state="$(rostopic echo /dji_sdk/flight_status/data -n1 | head -1)"

    # TAKEOFF: previously we were on the ground, now we're flying
    if [[ "$prev_state" -eq "$ON_GROUND" && "$state" -eq "$FLYING" ]]; then
        # start recording; let it run in the background
        echo "Takeoff detected, recording sensors and dji_sdk."
        bash "$script_full_path"/run_both.bash &
        prev_state="$FLYING"
        standby=false
    # LAND: previously we were flying, now we're on ground
    elif [[ "$prev_state" -eq "$FLYING" && "$state" -eq "$ON_GROUND" ]]; then
        # stop recording. make sure we "stop" completes before progressing
        echo "Landing detected, stopping sensors and dji_sdk."
        bash "$script_full_path"/stop_both.bash
        prev_state="$ON_GROUND"
        standby=true
    else
        echo "State="$state". No state change detected... waiting..."
        if [[ "$standby" = true ]]; then
            blink1-tool --white --blink 1 -q
        fi
    fi
    sleep 2
done
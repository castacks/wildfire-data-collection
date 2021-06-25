#!/bin/bash
# set -e
function cleanup(){
    blink1-tool --magenta --glimmer=2 -q
    blink1-tool --off -q
    exit
}

trap cleanup INT TERM

ORANGE=ffcc00

while true 
do
    # check RGB. Let RGB be Blue (cyan)
    rgb_works=`pgrep -f "gst-launch-1.0.*rgb\.mp4"`
    # echo "rgb: $rgb_works"
    if [ -n "$rgb_works" ]; then
        blink1-tool --cyan --blink 1 -q
    fi

    # check thermal. Let thermal be orange
    thermal_works=`pgrep -f "gst-launch-1.0.*thermal\.mp4"`
    # echo "thermal: $thermal_works"
    if [ -n "$thermal_works" ]; then
        blink1-tool --rgb "$ORANGE" --blink 1 -q
    fi

    # check recording. Let recording be green
    if rosnode list | grep -q "/data_collect"; then
        blink1-tool --green --blink 1 -q
    fi

    # sensors both don't work, let it be red
    if [ -z $thermal_works ] && [ -z $rgb_works ]; then
        blink1-tool --red --blink 1 -q
    fi


    # sleep 1
done

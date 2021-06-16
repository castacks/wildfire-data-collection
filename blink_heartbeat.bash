#!/bin/bash
# set -e
function cleanup(){
    blink1-tool --off 
    exit
}

trap cleanup INT TERM

ORANGE=ffcc00

while : 
do
    thermal_works=`pgrep -f "gst-launch-1.0.*thermal\.mp4"`
    # let thermal be orange
    # echo "thermal: $thermal_works"
    if [ -n "$thermal_works" ]; then
        blink1-tool --rgb "$ORANGE" --blink 1 -q
    fi
    rgb_works=`pgrep -f "gst-launch-1.0.*rgb\.mp4"`
    # echo "rgb: $rgb_works"
    if [ -n "$rgb_works" ]; then
        blink1-tool --cyan --blink 1 -q
    fi
    if [ -z $thermal_works ] && [ -z $rgb_works ]; then
        blink1-tool --red --blink 1 -q
    fi
    # sleep 1
done

# let RGB be cyan
# let none be red
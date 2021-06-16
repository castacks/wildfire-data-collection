#!/bin/bash
# tip: Make this file a shortcut, e.g. Ctrl-Alt-R
set -e

trap 'kill $(jobs -p %1)' INT TERM

script_name=$0
script_full_path=$(dirname "$0")


if [ -z "$1" ]; then
	ROOT=/media/wildfire/T7/wildfire
else
	ROOT="$1"
fi


[ -d "$ROOT" ] && echo "Directory $ROOT exists." || (echo "Error: Directory $ROOT does not exist." && exit 1)

DATETIME=$(date +"%Y-%m-%d_%H-%M-%S")
DATE=$(date +"%Y-%m-%d")
OUT_FOLDER="$ROOT"/"$DATE"
OUTPUT="$OUT_FOLDER"/"$DATETIME"_both
mkdir -p "$OUT_FOLDER"
echo "Saving to $OUTPUT ..."
sleep 2

# run RGB
gst-launch-1.0 -e nvarguscamerasrc sensor-id=0 ! tee name=t \
t. ! queue ! "video/x-raw(memory:NVMM),width=1920,height=1080,framerate=60/1" ! nvv4l2h264enc ! h264parse ! mp4mux ! filesink location="$OUTPUT"_rgb.mp4 \
t. ! queue ! nvvidconv ! xvimagesink &

# run thermal
gst-launch-1.0 -e \
v4l2src device=/dev/video1 ! video/x-raw,width=640,height=512,format=I420 ! tee name=t \
t. ! queue ! videoconvert ! omxh264enc ! queue ! mp4mux ! filesink location="$OUTPUT"_thermal.mp4 \
t. ! queue ! video/x-raw,width=640,height=512,format=I420 ! glimagesink &

# run status
bash "$script_full_path"/blink_heartbeat.bash
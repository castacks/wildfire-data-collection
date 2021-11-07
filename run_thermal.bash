#!/bin/bash
set -e

if [ -z ${script_full_path+x} ]; then 
	script_full_path=$(dirname "$0")
fi
echo "var is set to '$script_full_path'" 

source "$script_full_path"/constants.bash

if [ -z "$1" ]; then
	FOLDER="$DEFAULT_ROOT"
else
	FOLDER="$1"
fi


[ -d "$FOLDER" ] && echo "Directory $FOLDER exists." || (echo "Error: Directory $FOLDER does not exist." && exit 1)

DATETIME=$(date +"%Y-%m-%d_%H-%M-%S")
OUTPUT="$FOLDER/$DATETIME_both"
echo "Saving to $OUTPUT"

VIDEO_DEVICE="1"  # CHANGE ME IF NEEDED

# https://stackoverflow.com/a/52033580
(trap 'kill 0' SIGINT; \
gst-launch-1.0 -e \
v4l2src device=/dev/video"$VIDEO_DEVICE" ! video/x-raw,width=640,height=512,format=I420 ! tee name=t \
t. ! queue ! videoconvert ! omxh264enc ! queue ! mp4mux ! filesink location="$OUTPUT"_thermal.mp4 \
t. ! queue ! video/x-raw,width=640,height=512,format=I420 ! glimagesink
)

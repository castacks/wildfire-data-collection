#!/bin/bash
set -e

. ./constants.bash

if [ -z "$1" ]; then
	FOLDER="$DEFAULT_ROOT"
else
	FOLDER="$1"
fi


[ -d "$FOLDER" ] && echo "Directory $FOLDER exists." || (echo "Error: Directory $FOLDER does not exist." && exit 1)

DATETIME=$(date +"%Y-%m-%d_%H-%M-%S")
OUTPUT="$FOLDER/$DATETIME"
echo "Saving to $OUTPUT"

gst-launch-1.0 -e nvarguscamerasrc sensor-id=0 ! tee name=t \
t. ! queue ! "video/x-raw(memory:NVMM),width=1920,height=1080,framerate=60/1" ! nvv4l2h264enc ! h264parse ! mp4mux ! filesink location="$OUTPUT"_rgb.mp4 \
t. ! queue ! nvvidconv ! xvimagesink

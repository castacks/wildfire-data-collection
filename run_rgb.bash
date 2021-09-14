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
OUTPUT="$FOLDER/$DATETIME"
echo "Saving to $OUTPUT"

gst-launch-1.0 -e nvarguscamerasrc sensor-id=0 ! tee name=t \
t. ! queue ! "video/x-raw(memory:NVMM),width=2560,height=1440,framerate=40/1" ! nvvidconv flip-method=2 ! nvv4l2h264enc ! h264parse ! mp4mux ! filesink location="$OUTPUT"_rgb.mp4 \
t. ! queue ! nvvidconv flip-method=2 ! xvimagesink

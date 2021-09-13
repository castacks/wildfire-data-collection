#!/bin/bash
# tip: Make this file a shortcut, e.g. Ctrl-Alt-R
set -e

trap 'kill $(jobs -p %1)' INT TERM

script_name=$0
script_full_path=$(dirname "$0")

source "$script_full_path"/constants.bash


if [ -z "$1" ]; then
	ROOT="$DEFAULT_ROOT"
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
t. ! queue ! "video/x-raw(memory:NVMM),width=1920,height=1080,framerate=60/1" ! nvvidconv flip-method=2 ! nvv4l2h264enc ! h264parse ! mp4mux ! filesink location="$OUTPUT"_rgb.mp4 \
t. ! queue ! nvvidconv flip-method=2 ! xvimagesink &

# run thermal
gst-launch-1.0 -e \
v4l2src device=/dev/video1 ! video/x-raw,width=640,height=512,format=I420 ! tee name=t \
t. ! queue ! videoconvert ! omxh264enc ! queue ! mp4mux ! filesink location="$OUTPUT"_thermal.mp4 \
t. ! queue ! video/x-raw,width=640,height=512,format=I420 ! glimagesink &

# run ROS record
if rostopic list | grep -q "/rosout"; then
	source /home/wildfire/Development/dji_sample_ws/devel/setup.bash
	rosbag record -a -O "$OUT_FOLDER"/"$DATETIME"_dji_sdk.bag __name:="data_collect" &
else
	echo "roscore not running, not recording DJI SDK data"
fi

# run status
bash "$script_full_path"/blink_heartbeat.bash &

echo "Warning! Do not use Ctrl-C to stop! Use ./stop_both.bash"

wait

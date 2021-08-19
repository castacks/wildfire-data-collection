#!/bin/bash

if [ $# -eq 0 ]; then
	echo "No arguments supplied, setting cameras to 0 and 1"
	cameras=( 0 1 )
else
	cameras="$@"
fi


for cam in "${cameras[@]}"; do
	echo "CAM $cam:"
	v4l2-ctl -d"$cam" --list-formats-ext
done



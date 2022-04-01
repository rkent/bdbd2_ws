#!/bin/bash
#
# Usage: from this (docker) directoryL
# ./run.sh (name) (pgm) "(options)"

if [ -z "$1" ]
then
  NAME="ros2desktop"
else
  NAME=$1
fi

if [ -z "$2" ]
then
  PGM="bash"
else
  PGM=$2
fi

if [ -z "$3" ]
then
  OPTIONS="-it --rm"
else
  OPTIONS=$3
fi

docker run \
  --network=host \
  --volume=/tmp/.X11-unix:/tmp/.X11-unix \
  --volume="$HOME/.Xauthority:/home/ros/.Xauthority:rw" \
  --name=$NAME \
  --user=1000 \
  -v $(pwd)/..:/workspaces/bdbd2_ws \
  -v /home/kent/secrets:/secrets \
  --workdir="/workspaces/bdbd2_ws" \
  --env DISPLAY=$DISPLAY \
  --hostname=$NAME \
  $OPTIONS bdbd2/$NAME $PGM

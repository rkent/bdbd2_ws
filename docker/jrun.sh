#!/bin/bash
#
# Run docker containers on jetson devices
#
# Usage: from this (docker) directory
# ./run.sh (name) (pgm) "(options)"

if [ -z "$1" ]
then
  NAME="jtorch"
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
  --name=$NAME-r \
  --user=1000 \
  --runtime nvidia\
  -v $(pwd)/..:/workspaces/bdbd2_ws \
  -v /home/kent/secrets:/secrets \
  --env DISPLAY=$DISPLAY \
  --hostname=$NAME-r \
  --add-host "$NAME-r:127.0.0.1" \
  $OPTIONS bdbd2/$NAME $PGM
#  --workdir="/workspaces/bdbd2_ws" \

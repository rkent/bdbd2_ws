#!/bin/bash
docker run \
  --network=host \
  --cap-add="SYS_PTRACE" \
  --volume=/tmp/.X11-unix:/tmp/.X11-unix \
  --volume="$HOME/.Xauthority:/root/.Xauthority:rw" \
  --name=bdbd2_cam \
  -v $(pwd)/..:/workspaces/bdbd2_ws \
  -v /home/kent/secrets:/secrets \
  --rm -it \
  --workdir="/workspaces/bdbd2_ws" \
  --env DISPLAY=$DISPLAY \
  --privileged \
  dustynv/ros:galactic-ros-base-l4t-r32.6.1 bash

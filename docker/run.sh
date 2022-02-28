#!/bin/bash
docker run \
  --network=host \
  --cap-add="SYS_PTRACE" \
  --device=/dev/i2c-1 \
  --device=/dev/bus \
  --device=/dev/snd \
  --device=/dev/video0 \
  --device=/dev/video1 \
  --volume=/tmp/.X11-unix:/tmp/.X11-unix \
  --volume="$HOME/.Xauthority:/home/ros/.Xauthority:rw" \
  --name=bdbd2 \
  --user=ros \
  -v $(pwd)/..:/workspaces/bdbd2_ws \
  -v /home/kent/secrets:/secrets \
  --rm -it \
  --workdir="/workspaces/bdbd2_ws" \
  --env DISPLAY=$DISPLAY \
  bdbd2_ws:latest bash

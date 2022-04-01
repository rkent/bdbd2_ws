#!/bin/bash
# Build a docker container for this workspace

#docker build \
#  --build-arg ROS_DISTRO=rolling \
#  --build-arg I2C_GROUP=108 \
#  --tag bdbd2_ws:latest \
#  ../.devcontainer

source specs.sh

# Generate Dockerfiles
for key in ${!specs[@]}; do
  printf "\n building $key\n"
  docker build \
    --tag bdbd2/$key:latest \
    -f $key.Dockerfile \
    ..
done

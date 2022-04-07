#!/bin/bash
# Build a docker container for this workspace

#docker build \
#  --build-arg ROS_DISTRO=rolling \
#  --build-arg I2C_GROUP=108 \
#  --tag bdbd2_ws:latest \
#  ../.devcontainer

source generate.sh

if [ -z "$1" ]; then
  keys=${!specs[@]}
else
  keys="$1"
fi

echo "parm: $1"
echo "keys: $keys"

# Generate Dockerfiles
./generate.sh

# Build Dockerfiles
for key in $keys; do
  printf "\n building $key\n"
  docker build \
    --tag bdbd2/$key:latest \
    -f $key.Dockerfile \
    ..
done

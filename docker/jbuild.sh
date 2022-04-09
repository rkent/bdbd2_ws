#!/bin/bash
# Build a docker container for this workspace

source jgenerate.sh

if [ -z "$1" ]; then
  keys=${!specs[@]}
else
  keys="$1"
fi

echo "parm: $1"
echo "keys: $keys"

# Build Dockerfiles
for key in $keys; do
  printf "\n building $key\n"
  docker build \
    --tag bdbd2/$key:latest \
    -f $key.Dockerfile \
    ..
done

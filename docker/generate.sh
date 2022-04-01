#!/bin/bash

# Generate Dockerfiles

source specs.sh

# Generate Dockerfiles
for key in ${!specs[@]}; do
  printf "## $key Dockerfile\n\n" > $key.Dockerfile
  spec=${specs[$key]}
  for f in $spec; do
    cat $f.frag >> $key.Dockerfile
  done
done

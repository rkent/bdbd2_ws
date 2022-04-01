## BDBD2 docker definitions

This folder contains files to specify various docker builds that can be used either directly, or from vscode. The file specs.sh contains definitions of various builds.

generate.sh generates the Dockerfiles

build.sh does the actual builds.

The context for these builds is the workspace folder (that is the parent of this folder) but ```build.sh``` and ```generate.sh``` should be run from this (the docker) folder.


#!/bin/bash

# install workspace dependencies
#sudo rosdep init
#sudo apt-get update
#rosdep update --rosdistro $ROS_DISTRO
rosdep install --ignore-src --from-paths src/audio_common/audio_common_msgs --from-paths src/bdbd2/bdbd2_msgs -y

# Dockerfile fragment to add dev features to ROS
# ARG ROS_DISTRO=rolling

ENV DEBIAN_FRONTEND=noninteractive
RUN apt-get install -y \
  bash-completion \
  build-essential \
  cmake \
  gdb \
  git \
  nano \
  pylint3 \
  python3-argcomplete \
  python3-colcon-common-extensions \
  python3-pip \
  python3-rosdep \
  python3-vcstool \
  sudo \
  vim \
  wget \
  # Install ros distro testing packages
  ros-${ROS_DISTRO}-ament-lint \
  ros-${ROS_DISTRO}-launch-testing \
  ros-${ROS_DISTRO}-launch-testing-ament-cmake \
  ros-${ROS_DISTRO}-launch-testing-ros \
  python3-autopep8 \
  # && rm -rf /var/lib/apt/lists/* \
  && rosdep init || echo "rosdep already initialized"

# Config of git
RUN git config --system user.email "kent@caspia.com" \
  && git config --system user.name "R. Kent James"

COPY docker/show_git_branch.sh /tmp/show_git_branch.sh
RUN cat /tmp/show_git_branch.sh >> /home/$USERNAME/.bashrc
ENV DEBIAN_FRONTEND=


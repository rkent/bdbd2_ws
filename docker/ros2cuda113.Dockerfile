## ros2cuda113 Dockerfile

# Dockerfile fragment for ubuntu20

##############################################
# Adapted from:
# https://github.com/athackst/dockerfiles/blob/main/ros2/galactic.Dockerfile
##############################################

FROM nvidia/cuda:11.3.1-base-ubuntu20.04

ARG USERNAME=bdbd2
ARG USER_UID=1000
ARG USER_GID=$USER_UID

ENV DEBIAN_FRONTEND=noninteractive

# Install language
RUN apt-get update && apt-get install -y \
  locales \
  && locale-gen en_US.UTF-8 \
  && update-locale LC_ALL=en_US.UTF-8 LANG=en_US.UTF-8 \
  && rm -rf /var/lib/apt/lists/*
ENV LANG en_US.UTF-8

# Install timezone, sudo
RUN ln -fs /usr/share/zoneinfo/UTC /etc/localtime \
  && export DEBIAN_FRONTEND=noninteractive \
  && apt-get update \
  && apt-get install -y tzdata \
  && dpkg-reconfigure --frontend noninteractive tzdata \
  && rm -rf /var/lib/apt/lists/*

# Add expected utilities
RUN apt-get update \
  && apt-get install -y \
  sudo \
  wget \
  less \
  nano \
  bzip2 \
  && rm -rf /var/lib/apt/lists/*

# Create a non-root user
RUN groupadd --gid $USER_GID $USERNAME \
  && useradd -s /bin/bash --uid $USER_UID --gid $USER_GID -m $USERNAME \
  # [Optional] Add sudo support for the non-root user
  && echo $USERNAME ALL=\(root\) NOPASSWD:ALL > /etc/sudoers.d/$USERNAME\
  && chmod 0440 /etc/sudoers.d/$USERNAME

RUN echo "PATH=~/.local/bin:$PATH" >> /home/$USERNAME/.bashrc
ENV force_color_prompt=yes
ENV DEBIAN_FRONTEND=

# Dockerfile fragment to install ros2 base from a repository
ARG ROS_DISTRO=rolling
# ARG USERNAME=bdbd2

# Install ROS2
ENV ROS_DISTRO=${ROS_DISTRO}
RUN apt-get update && apt-get install -y \
    curl \
    gnupg2 \
    lsb-release \
    sudo \
  && curl -sSL https://raw.githubusercontent.com/ros/rosdistro/master/ros.key -o /usr/share/keyrings/ros-archive-keyring.gpg \
  && echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/ros-archive-keyring.gpg] http://packages.ros.org/ros2/ubuntu $(lsb_release -cs) main" | tee /etc/apt/sources.list.d/ros2.list > /dev/null \
  && apt-get update && apt-get install -y \
    ros-${ROS_DISTRO}-ros-base \
    ros-${ROS_DISTRO}-rmw-cyclonedds-cpp \
    python3-argcomplete

RUN echo 'ROS_SETUP=$(find /workspaces -path *install/setup.bash | head -n 1)' >> /home/$USERNAME/.bashrc \
  && echo 'if [ -z "${ROS_SETUP}" ]; then ROS_SETUP=/opt/ros/${ROS_DISTRO}/setup.bash; fi' >> /home/$USERNAME/.bashrc \
  && echo 'if [ -f "${ROS_SETUP}" ]; then source "${ROS_SETUP}"; fi' >> /home/$USERNAME/.bashrc

ENV AMENT_PREFIX_PATH=/opt/ros/${ROS_DISTRO}
ENV COLCON_PREFIX_PATH=/opt/ros/${ROS_DISTRO}
ENV LD_LIBRARY_PATH=/opt/ros/${ROS_DISTRO}/lib
ENV PATH=/opt/ros/${ROS_DISTRO}/bin:$PATH
ENV PYTHONPATH=/opt/ros/${ROS_DISTRO}/lib/python3.8/site-packages
ENV ROS_PYTHON_VERSION=3
ENV ROS_VERSION=2
ENV RMW_IMPLEMENTATION=rmw_cyclonedds_cpp
ENV DEBIAN_FRONTEND=

# setup entrypoint
COPY ./docker/ros_entrypoint.sh /

ENTRYPOINT ["/ros_entrypoint.sh"]
CMD ["bash"]
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

# Dockerfile fragment to add desktop features to ROS
# ARG ROS_DISTRO=rolling

ENV DEBIAN_FRONTEND=noninteractive
# Install the full release
RUN apt-get update && apt-get install -y \
  ros-${ROS_DISTRO}-desktop \
  && rm -rf /var/lib/apt/lists/*
ENV DEBIAN_FRONTEND=


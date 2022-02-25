##############################################
# Adapted from:
# https://github.com/athackst/dockerfiles/blob/main/ros2/galactic.Dockerfile
##############################################

##############################################
# Created from template ros2.dockerfile.jinja
##############################################

###########################################
# Base image 
###########################################
FROM ubuntu:20.04 AS base
ARG ROS_DISTRO=rolling
# The group number for the i2c group
ARG I2C_GROUP=110

ENV DEBIAN_FRONTEND=noninteractive

# Install language
RUN apt-get update && apt-get install -y \
  locales \
  && locale-gen en_US.UTF-8 \
  && update-locale LC_ALL=en_US.UTF-8 LANG=en_US.UTF-8 \
  && rm -rf /var/lib/apt/lists/*
ENV LANG en_US.UTF-8

# Install timezone
RUN ln -fs /usr/share/zoneinfo/UTC /etc/localtime \
  && export DEBIAN_FRONTEND=noninteractive \
  && apt-get update \
  && apt-get install -y tzdata \
  && dpkg-reconfigure --frontend noninteractive tzdata \
  && rm -rf /var/lib/apt/lists/*

# Create the i2c group before any others take over its number
RUN groupadd -g ${I2C_GROUP} i2c

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
    python3-argcomplete

ENV AMENT_PREFIX_PATH=/opt/ros/${ROS_DISTRO}
ENV COLCON_PREFIX_PATH=/opt/ros/${ROS_DISTRO}
ENV LD_LIBRARY_PATH=/opt/ros/${ROS_DISTRO}/lib
ENV PATH=/opt/ros/${ROS_DISTRO}/bin:$PATH
ENV PYTHONPATH=/opt/ros/${ROS_DISTRO}/lib/python3.8/site-packages
ENV ROS_PYTHON_VERSION=3
ENV ROS_VERSION=2
ENV DEBIAN_FRONTEND=

###########################################
#  Develop image 
###########################################
FROM base AS dev

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

ARG USERNAME=ros
ARG USER_UID=1000
ARG USER_GID=$USER_UID

# Create a non-root user
RUN groupadd --gid $USER_GID $USERNAME \
  && useradd -s /bin/bash --uid $USER_UID --gid $USER_GID -m $USERNAME \
  && usermod -aG i2c $USERNAME \
  # [Optional] Add sudo support for the non-root user
  && echo $USERNAME ALL=\(root\) NOPASSWD:ALL > /etc/sudoers.d/$USERNAME\
  && chmod 0440 /etc/sudoers.d/$USERNAME \
  && echo "source /usr/share/bash-completion/completions/git" >> /home/$USERNAME/.bashrc \
  && echo 'ROS_SETUP=$(find /workspaces -path *install/setup.bash | head -n 1)' >> /home/$USERNAME/.bashrc \
  && echo 'if [ -z "${ROS_SETUP}" ]; then ROS_SETUP=/opt/ros/${ROS_DISTRO}/setup.bash; fi' >> /home/$USERNAME/.bashrc \
  && echo 'if [ -f "${ROS_SETUP}" ]; then source "${ROS_SETUP}"; fi' >> /home/$USERNAME/.bashrc
ENV DEBIAN_FRONTEND=

###########################################
#  Full image 
###########################################
FROM dev AS full

ENV DEBIAN_FRONTEND=noninteractive
# Install the full release
RUN apt-get update && apt-get install -y \
  ros-${ROS_DISTRO}-desktop \
  && rm -rf /var/lib/apt/lists/*
ENV DEBIAN_FRONTEND=

###########################################
#  Full+Gazebo image 
###########################################
FROM full AS gazebo

ENV DEBIAN_FRONTEND=noninteractive
# Install gazebo
RUN apt-get update && apt-get install -y \
  ros-${ROS_DISTRO}-gazebo* \
  && rm -rf /var/lib/apt/lists/*
ENV DEBIAN_FRONTEND=

###########################################
#  Full+Gazebo+Nvidia image 
###########################################

FROM gazebo AS gazebo-nvidia

################
# Expose the nvidia driver to allow opengl 
# Dependencies for glvnd and X11.
################
RUN apt-get update \
 && apt-get install -y -qq --no-install-recommends \
  libglvnd0 \
  libgl1 \
  libglx0 \
  libegl1 \
  libxext6 \
  libx11-6

# Env vars for the nvidia-container-runtime.
ENV NVIDIA_VISIBLE_DEVICES all
ENV NVIDIA_DRIVER_CAPABILITIES graphics,utility,compute
ENV QT_X11_NO_MITSHM 1

# Extra additions to support bdbd2
FROM dev as bdbd2 
# tweaks to move upstream eventually
RUN apt-get install -y \
  python-is-python3 \
  doxygen \
  graphviz \
  i2c-tools \
  espeak-ng \
  python3-pyaudio \
  alsa-utils

# RUN rosdep update && rosdep install --from-paths src --ignore-src -r -y
RUN pip install smbus
RUN pip install google-cloud-texttospeech
RUN pip install google-cloud-speech
RUN pip install py-espeak-ng

# Respeaker firmware
#RUN pip install py-espeak-ng
#RUN pip install pyusb click
#RUN git clone https://github.com/respeaker/usb_4_mic_array.git /home/ros/respeaker

# bash additions
COPY bashrc_add.sh /tmp/
RUN cat /tmp/bashrc_add.sh >> /home/ros/.bashrc

#RUN apt-get install -y \
#  usbutils \
#  pulseaudio

#COPY 60-respeaker.rules /etc/udev/rules.d
COPY asound.conf /etc/
#COPY pulse.conf /tmp/pulse.conf
#RUN cat /tmp/pulse.conf >> /etc/pulse/default.pa
#RUN pip install Jetson.GPIO
#RUN pip install adafruit-circuitpython-ina260
RUN groupadd -f -r gpio
RUN usermod -aG audio ros
RUN usermod -aG gpio ros
#ENV BLINKA_FORCEBOARD JETSON_NANO

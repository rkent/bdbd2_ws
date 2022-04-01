## ubuntu20 Dockerfile

# Dockerfile fragment for ubuntu20

##############################################
# Adapted from:
# https://github.com/athackst/dockerfiles/blob/main/ros2/galactic.Dockerfile
##############################################

FROM ubuntu:20.04

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


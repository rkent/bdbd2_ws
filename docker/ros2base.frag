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

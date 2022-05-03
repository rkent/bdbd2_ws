#!/bin/bash
#
# Build ros2 from source on ubuntu 18
# Adapted from https://github.com/dusty-nv/jetson-containers/Dockerfile.ros.galactic
#
ROS_DISTRO=${1:-galactic}
ROS_PKG=ros_base
echo "ROS_DISTRO is $ROS_DISTRO"

export ROS_ROOT=/opt/ros/${ROS_DISTRO}

DEBIAN_FRONTEND=noninteractive
cd /tmp

# change the locale from POSIX to UTF-8
sudo locale-gen en_US en_US.UTF-8
sudo update-locale LC_ALL=en_US.UTF-8 LANG=en_US.UTF-8
LANG=en_US.UTF-8
PYTHONIOENCODING=utf-8

# 
# add the ROS deb repo to the apt sources list
#
sudo apt-get update
sudo apt-get install -y --no-install-recommends \
		curl \
		wget \
		gnupg2 \
		lsb-release \
		ca-certificates

sudo curl -sSL https://raw.githubusercontent.com/ros/rosdistro/master/ros.key -o /usr/share/keyrings/ros-archive-keyring.gpg
echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/ros-archive-keyring.gpg] http://packages.ros.org/ros2/ubuntu $(lsb_release -cs) main" | sudo tee /etc/apt/sources.list.d/ros2.list > /dev/null

# 
# install development packages
#
sudo apt-get update
sudo apt-get install -y --no-install-recommends \
		build-essential \
		cmake \
		git \
		libbullet-dev \
		libpython3-dev \
		python3-colcon-common-extensions \
		python3-flake8 \
		python3-pip \
		python3-numpy \
		python3-pytest-cov \
		python3-rosdep \
		python3-setuptools \
		python3-vcstool \
		python3-rosinstall-generator \
		libasio-dev \
		libtinyxml2-dev \
		libcunit1-dev \
		libgazebo9-dev \
		gazebo9 \
		gazebo9-common \
		gazebo9-plugin-base

# install some pip packages needed for testing
sudo python3 -m pip install -U \
		argcomplete \
		flake8-blind-except \
		flake8-builtins \
		flake8-class-newline \
		flake8-comprehensions \
		flake8-deprecated \
		flake8-docstrings \
		flake8-import-order \
		flake8-quotes \
		pytest-repeat \
		pytest-rerunfailures \
		pytest

# 
# install OpenCV (with CUDA)
#
OPENCV_URL=https://nvidia.box.com/shared/static/5v89u6g5rb62fpz4lh0rz531ajo2t5ef.gz
OPENCV_DEB=OpenCV-4.5.0-aarch64.tar.gz

sudo apt-get purge -y '*opencv*' || echo "previous OpenCV installation not found"
mkdir opencv && cd opencv
wget --quiet --show-progress --progress=bar:force:noscroll --no-check-certificate ${OPENCV_URL} -O ${OPENCV_DEB} && \
tar -xzvf ${OPENCV_DEB}
sudo dpkg -i --force-depends *.deb
sudo apt-get install -y -f --no-install-recommends
sudo dpkg -i *.deb
cd ../
rm -rf opencv
sudo cp -r /usr/include/opencv4 /usr/local/include/opencv4
sudo cp -r /usr/lib/python3.6/dist-packages/cv2 /usr/local/lib/python3.6/dist-packages/cv2
    
# 
# upgrade cmake - https://stackoverflow.com/a/56690743
# this is needed to build some of the ROS2 packages
#
sudo apt-get install -y --no-install-recommends \
		  software-properties-common \
		  apt-transport-https \
		  ca-certificates \
		  gnupg
		  	  
wget -qO - https://apt.kitware.com/keys/kitware-archive-latest.asc | sudo apt-key add -
sudo apt-add-repository 'deb https://apt.kitware.com/ubuntu/ bionic main'
sudo apt-get update
sudo apt-get install -y --no-install-recommends --only-upgrade \
            cmake
    
cmake --version

# 
# download/build ROS from source
#
sudo mkdir -p ${ROS_ROOT}
sudo chown $USER:$USER ${ROS_ROOT}

cd ${ROS_ROOT}

# https://answers.ros.org/question/325245/minimal-ros2-installation/?answer=325249#post-id-325249
rosinstall_generator --deps --rosdistro ${ROS_DISTRO} ${ROS_PKG} \
		launch_xml \
		launch_yaml \
		launch_testing \
		launch_testing_ament_cmake \
		demo_nodes_cpp \
		demo_nodes_py \
		example_interfaces \
		camera_calibration_parsers \
		camera_info_manager \
		cv_bridge \
		v4l2_camera \
		vision_opencv \
		vision_msgs \
		image_geometry \
		image_pipeline \
		image_transport \
		compressed_image_transport \
		compressed_depth_image_transport \
		> ros2.${ROS_DISTRO}.${ROS_PKG}.rosinstall

cd ${ROS_ROOT} && rm -rf src && mkdir -p src && cat ros2.${ROS_DISTRO}.${ROS_PKG}.rosinstall && \
    vcs import src < ros2.${ROS_DISTRO}.${ROS_PKG}.rosinstall

# install dependencies using rosdep
sudo rosdep init
rosdep update && \
    rosdep install -y \
   	  --ignore-src \
      --from-paths src \
	  --rosdistro ${ROS_DISTRO} \
	  --skip-keys "libopencv-dev libopencv-contrib-dev libopencv-imgproc-dev python-opencv python3-opencv"

    # build it!
cd ${ROS_ROOT} && colcon build \
        --merge-install \
        --cmake-args -DCMAKE_BUILD_TYPE=Release
    
exit 0
    # remove build files
    rm -rf ${ROS_ROOT}/src && \
    rm -rf ${ROS_ROOT}/logs && \
    rm -rf ${ROS_ROOT}/build && \
    rm ${ROS_ROOT}/*.rosinstall
    
    
#
# fix broken package.xml in test_pluginlib that crops up if/when rosdep is run again
#
#   Error(s) in package '/opt/ros/foxy/build/pluginlib/prefix/share/test_pluginlib/package.xml':
#   Package 'test_pluginlib' must declare at least one maintainer
#   The package node must contain at least one "license" tag
#
#RUN TEST_PLUGINLIB_PACKAGE="${ROS_ROOT}/build/pluginlib/pluginlib_enable_plugin_testing/install/test_pluginlib__test_pluginlib/share/test_pluginlib/package.xml" && \
#    sed -i '/<\/description>/a <license>BSD<\/license>' $TEST_PLUGINLIB_PACKAGE && \
#    sed -i '/<\/description>/a <maintainer email="michael@openrobotics.org">Michael Carroll<\/maintainer>' $TEST_PLUGINLIB_PACKAGE && \
#    cat $TEST_PLUGINLIB_PACKAGE
    
    
#
# Set the default DDS middleware to cyclonedds
# https://github.com/ros2/rclcpp/issues/1335
#
ENV RMW_IMPLEMENTATION=rmw_cyclonedds_cpp


#
# setup entrypoint
#
COPY ./packages/ros_entrypoint.sh /ros_entrypoint.sh

RUN sed -i \
    's/ros_env_setup="\/opt\/ros\/$ROS_DISTRO\/setup.bash"/ros_env_setup="${ROS_ROOT}\/install\/setup.bash"/g' \
    /ros_entrypoint.sh && \
    cat /ros_entrypoint.sh

RUN echo 'source ${ROS_ROOT}/install/setup.bash' >> /root/.bashrc

ENTRYPOINT ["/ros_entrypoint.sh"]
CMD ["bash"]
WORKDIR /

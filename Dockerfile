FROM ros:noetic

#LABEL maintainer="iory ab.ioryz@gmail.com"

ENV ROS_DISTRO noetic

RUN apt -q -qq update && \
  DEBIAN_FRONTEND=noninteractive apt install -y \
  software-properties-common \
  wget


RUN echo 'deb http://realsense-hw-public.s3.amazonaws.com/Debian/apt-repo focal main' || tee /etc/apt/sources.list.d/realsense-public.list
RUN apt-key adv --keyserver keys.gnupg.net --recv-key F6E65AC044F831AC80A06380C8B3A55A6F3EFCDE || sudo apt-key adv --keyserver hkp://keyserver.ubuntu.com:80 --recv-key F6E65AC044F831AC80A06380C8B3A55A6F3EFCDE
RUN add-apt-repository "deb https://librealsense.intel.com/Debian/apt-repo focal main" -u
RUN apt-get update -qq
RUN apt-get install librealsense2-dkms --allow-unauthenticated -y
RUN apt-get install librealsense2-dev --allow-unauthenticated -y

RUN apt -q -qq update && \
  DEBIAN_FRONTEND=noninteractive apt install -y --allow-unauthenticated \
  python3-rosinstall \
  python3-catkin-tools \
  python3-pip \ 
  python3-catkin-lint \
  python3-osrf-pycommon \
  ros-${ROS_DISTRO}-jsk-tools \
  ros-${ROS_DISTRO}-rgbd-launch \
  ros-${ROS_DISTRO}-image-transport-plugins \
  ros-${ROS_DISTRO}-image-transport

RUN rosdep update

RUN apt-get update && \
    apt-get upgrade -y && \
    apt-get install -y git

RUN mkdir -p /catkin_ws/src && cd /catkin_ws/src && \
  git clone --depth 1 https://github.com/IntelRealSense/realsense-ros.git && \
  git clone --depth 1 https://github.com/pal-robotics/ddynamic_reconfigure
RUN cd catkin_ws;
RUN mv /bin/sh /bin/sh_tmp && ln -s /bin/bash /bin/sh
RUN source /opt/ros/${ROS_DISTRO}/setup.bash; cd catkin_ws; catkin build -DCATKIN_ENABLE_TESTING=False -DCMAKE_BUILD_TYPE=Release
RUN rm /bin/sh && mv /bin/sh_tmp /bin/sh
RUN touch /root/.bashrc && \
  echo "source /catkin_ws/devel/setup.bash\n" >> /root/.bashrc && \
  echo "rossetip\n" >> /root/.bashrc && \
  echo "rossetmaster localhost"

#RUN rosdep install image_pipeline

RUN rm -rf /var/lib/apt/lists/*

COPY ./ros_entrypoint.sh /
ENTRYPOINT ["/ros_entrypoint.sh"]

CMD ["bash"]

docker run -it --rm --net=host  --mount type=bind,source="$(pwd)"/mounted,target=/mounted --privileged --volume=/dev:/dev -it realsense-ros-docker:noetic

# Start with the ROS Noetic base image for Ubuntu 20.04 (Focal)
FROM ros:noetic-ros-base-focal

# Avoid interactive prompts during apt-get install
ENV DEBIAN_FRONTEND=noninteractive

# Update apt-get and install ROS dependencies, Gazebo, RViz, Tilix, X11 apps
RUN apt-get update && apt-get install -y \
    ros-noetic-rospy-tutorials \
    gazebo11 \
    rviz \
    tilix \
    x11-apps \
    sudo \
    && rm -rf /var/lib/apt/lists/*

# Create a non-root user for GUI applications (important for X11)
ARG USERNAME=rosuser
ARG USER_UID=1000
ARG USER_GID=1000

RUN groupadd --gid $USER_GID $USERNAME \
    && useradd -m -s /bin/bash --uid $USER_UID --gid $USER_GID $USERNAME \
    && echo "$USERNAME ALL=(ALL) NOPASSWD:ALL" >> /etc/sudoers

# Set user to the non-root user
USER $USERNAME
WORKDIR /home/$USERNAME

# Ensure ROS is sourced in every new shell
RUN echo "source /opt/ros/noetic/setup.bash" >> ~/.bashrc

# Default command to run when the container starts (you can override this)
CMD ["bash"]

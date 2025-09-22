# ROS1_ROS2_Bridge_Jetson_Devices

Isolated Dockerized setup for ROS1 (Noetic), ROS2 (Humble) and the ROS1–ROS2 bridge. Each runs in a separate container to avoid dependency conflicts. The setup uses the [`dustynv/ros:humble-desktop-l4t-r36.4.0`](https://hub.docker.com/layers/dustynv/ros/humble-desktop-l4t-r36.4.0/images/sha256-b8ee30b1ae189cfeeea755a7fd6b8aea74267f5c1bc0cfa4f19a6acec9d941e5) image (optimized for Jetson hardware) for ROS2 and the bridge, enabling seamless communication between ROS1 and ROS2 via the [ros1_bridge](https://github.com/ros2/ros1_bridge) package.

## Prerequisites

Before running this project, make sure you have:
 - system running Ubuntu 22.04+
 - Docker installed
 - Docker compose installed
  
 ### Install Docker
Docker allows us to build, run, and manage containerized applications.
```bash
sudo apt update
sudo apt install -y docker.io
```
 - **Add User to Docker Group**

  By default, Docker requires sudo to run. To avoid typing sudo each time, add your current user to the **docker** group:

```bash
sudo usermod -aG docker $USER 
newgrp docker # Apply new group
# OR logout and re-login completely
```
 - **Verify Docker Installation**

Start the Docker serivce
```bash 
sudo service docker start
sudo service docker status
docker info #check if Docker is running
docker run -it --rm hello-world #Run a test container:
```
If you see a **Hello from Docker!** message, your installation is successful .

### Install Docker Compose (via Ubuntu repository)
  Docker Compose allows you to define and run multi-container applications.  
  The official installation instructions are available here: [Docker Docs: Install Compose](https://docs.docker.com/compose/install/)  

  ```bash
  sudo apt-get update
  sudo apt-get install -y docker-compose-plugin
  ```
- **Verify Docker Compose Installation**

```bash
docker compose version
```

## Installation Guide

### 1. Build the ROS2 Humble – ROS1 Bridge

The ros-humble-ros1-bridge package enables communication between ROS 1 and ROS 2 (Humble).

- **Clone the repository**

```bash
cd ~
git clone https://github.com/TommyChangUMD/ros-humble-ros1-bridge-builder.git
```

- **Build the Docker image**
  
```bash
cd ros-humble-ros1-bridge-builder/
docker build . -t ros-humble-ros1-bridge-builder
```

- **Build the bridge package**
  
Extract the built package into your home directory:
```bash
cd ~/
docker run --rm ros-humble-ros1-bridge-builder | tar xvzf -
```

### 2. Clone the Repository

Clone this repository to get the `Dockerfile` and `docker-compose.yml`

```bash
git clone https://github.com/VishnuArimbra/ros1_ros2_bridge_jetson_orin_nano.git
cd ros1_ros2_bridge_jetson_orin_nano
```

### 3. Build the Docker Image

This repository contains a **Dockerfile** that extends the official [`ros:noetic-ros-base-focal`](https://hub.docker.com/layers/library/ros/noetic-ros-base-focal/images/sha256-ed655ce2187b5915ce130f9ff76436bfe8e526576d42ff1c4dbe1cf6fe400251) image.  

It installs additional useful packages such as:  
- ROS tutorials (`ros-noetic-rospy-tutorials`)  
- Gazebo 11 (for simulation)  
- RViz (for visualization)  
- Tilix (terminal emulator)  
- X11 apps (for GUI forwarding)  

**Run the build command from inside the `ros1_ros2_bridge_jetson_orin_nano` folder**

```bash
docker build -t ros1-noetic .
```
Here, `ros1-noetic` is the name given to the image (you can change it).

### 4. Run with Docker Compose

Use the provided `docker-compose.yml` to start the container.

**Bash terminal 1**

```bash
docker compose up
```
This opens 3 containers.

The `ros1-noetic-container` will be launched in a Tilix terminal. `ros2-humble-container` and `ros1-ros2-bridge-container` opens in background.

> **Note**:`docker compose up` will start the `ros1-noetic` (custom) image and pull [`dustynv/ros:humble-desktop-l4t-r36.4.0`](https://hub.docker.com/layers/dustynv/ros/humble-desktop-l4t-r36.4.0/images/sha256-b8ee30b1ae189cfeeea755a7fd6b8aea74267f5c1bc0cfa4f19a6acec9d941e5), if it's not available locally.
> 
> If an error occurs due to the missing ROS 2 image, run:
```bash
docker pull dustynv/ros:humble-desktop-l4t-r36.4.0
```

### 5. Run the ROS1–ROS2 Bridge

**Tilix terminal 1**
```bash
source /opt/ros/noetic/setup.bash
roscore
```
**Bash terminal 2**

Access the ros2-humble-container

```bash
docker exec -it ros2-humble-container bash
```
### 6. Testing

**Tilix terminal 2**

Open a new terminal in the `ros1-noetic-container`
```bash
rosrun rospy_tutorials talker
```

**Bash terminal 2**

```bash
source /opt/ros/humble/install/setup.bash
ros2 run demo_nodes_cpp listener
```

## References

- https://github.com/TommyChangUMD/ros-humble-ros1-bridge-builder
- https://github.com/ros2/ros1_bridge
- https://jaypr.notion.site/ROS2-Humble-ROS1-Noetic-Bridge-Tutorial-using-ros1_bridge-c158e43e755c440e9dd378288df1e3d6

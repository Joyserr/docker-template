
## ✨ Features

- ✅ **Permission Consistency**: Container user UID/GID matches host to avoid file permission issues
- ✅ **GUI Support**: Supports GUI tools like RViz and rqt (via X11 forwarding)
- ✅ **Workspace Mounting**: Real-time synchronization of host workspace to container
- ✅ **Network Interoperability**: Uses host network mode to simplify ROS node communication
- ✅ **Multiple Usage Options**: Supports Makefile, Shell scripts, and Docker Compose

## 🚀 Quick Start

### Prerequisites

- Docker installed (version >= 19.03)
- Docker Compose installed (optional)
- Make tool (optional, recommended)

### 1. Configure Environment Variables

View and modify the `docker/.env` file as needed:

```bash
# User configuration (automatically configured for current host user)
USER_NAME=duboping
USER_UID=1000
USER_GID=1000

# Docker image configuration
IMAGE_NAME=ros-kudan-dev
IMAGE_TAG=latest
CONTAINER_NAME=kudan_ws_container

# ROS distribution configuration
ROS_DISTRO=noetic

# Workspace path
WORKSPACE_DIR=/home/duboping/public/kudan/kudan_ws
```

### 2. Build Docker Image

**Method 1: Using Makefile (Recommended)**

```bash
make build
```

**Method 2: Using Shell Script**

```bash
./docker/scripts/docker-build.sh
```

**Method 3: Using Docker Compose**

```bash
cd docker
docker-compose build
```

### 3. Run Container

**Method 1: Interactive Run (Container auto-deletes on exit)**

```bash
# Using Makefile
make run

# Using Shell script
./docker/scripts/docker-run.sh
```

**Method 2: Background Run**

```bash
# Using Makefile
make run-detach

# Using Shell script
./docker/scripts/docker-run-detach.sh

# Using Docker Compose
cd docker
docker-compose up -d
```

### 4. Enter Container

If the container is running in the background, use the following commands to enter:

```bash
# Using Makefile
make exec

# Using Shell script
./docker/scripts/docker-exec.sh

# Using Docker Compose
cd docker
docker-compose exec ros-dev bash
```

## 📖 Detailed Usage Instructions

### Makefile Commands

View all available commands:

```bash
make help
```

Common Commands:

| Command | Description |
|---------|-------------|
| `make help` | Display help information |
| `make build` | Build Docker image |
| `make run` | Run container (interactive) |
| `make run-detach` | Run container in background |
| `make exec` | Enter running container |
| `make stop` | Stop and remove container |
| `make clean` | Clean containers and images |
| `make rebuild` | Clean and rebuild image |
| `make logs` | View container logs |
| `make status` | View container status |

### Shell Script Usage

All scripts are located in the `docker/scripts/` directory with executable permissions:

```bash
# Build image
./docker/scripts/docker-build.sh

# Run container (interactive)
./docker/scripts/docker-run.sh

# Run container in background
./docker/scripts/docker-run-detach.sh

# Enter container
./docker/scripts/docker-exec.sh

# Stop container
./docker/scripts/docker-stop.sh
```

### Docker Compose Usage

```bash
# Navigate to docker directory
cd docker

# Build and start
docker-compose up -d

# Enter container
docker-compose exec ros-dev bash

# View logs
docker-compose logs -f

# Stop
docker-compose down

# Rebuild
docker-compose build --no-cache
```

## 🔧 Development Inside Container

### ROS Environment

ROS environment is automatically configured inside the container and ready to use upon startup:

```bash
# Check ROS environment
echo $ROS_DISTRO  # Should output: noetic

# Check ROS version
rosversion -d

# Build workspace
cd ~/catkin_ws
catkin_make

# Or use catkin build (recommended)
catkin build
```

### Predefined Aliases

The following bash aliases are configured inside the container:

```bash
cm    # catkin_make
cs    # cd ~/catkin_ws/src
cw    # cd ~/catkin_ws
```

### Install Additional Dependencies

```bash
# Install ROS packages
sudo apt-get update
sudo apt-get install ros-noetic-<package-name>

# Install dependencies using rosdep
cd ~/catkin_ws
rosdep install --from-paths src --ignore-src -r -y
```

## 🖥️ GUI Application Support

### RViz Example

```bash
# Run inside container
roscore &
rviz
```

### rqt Tools

```bash
# Run inside container
rqt
```

If you encounter GUI display issues, execute on the host:

```bash
xhost +local:docker
```

## 📝 Common Issues

### 1. Permission Issues

**Problem**: Files created inside container are inaccessible on host

**Solution**: Ensure `USER_UID` and `USER_GID` in `.env` file match host user. Check with:

```bash
id -u  # Check UID
id -g  # Check GID
```

### 2. GUI Not Displaying

**Problem**: RViz or rqt won't start

**Solution**: Allow Docker to access X11 on host:

```bash
xhost +local:docker
```

If using SSH connection, enable X11 forwarding:

```bash
ssh -X user@host
```

### 3. Network Connection Issues

**Problem**: ROS nodes can't communicate

**Solution**: Ensure container uses `--network host` mode (already set in config files)

### 4. Container Name Conflicts

**Problem**: Container name already exists

**Solution**: Stop and remove old container first:

```bash
make stop
# Or
docker stop kudan_ws_container && docker rm kudan_ws_container
```

## 🔄 Workflow Examples

### Typical Development Workflow

```bash
# 1. Build image (first time or after Dockerfile modification)
make build

# 2. Start container in background
make run-detach

# 3. Enter container
make exec

# 4. Develop inside container
cd ~/catkin_ws/src
# ... write code ...
cd ~/catkin_ws
catkin_make
source devel/setup.bash
rosrun <package> <node>

# 5. Exit container (container continues running)
exit

# 6. Re-enter when needed
make exec

# 7. Stop container when done
make stop
```

### Multi-terminal Work

```bash
# Terminal 1: Start roscore
make run-detach
make exec
roscore

# Terminal 2: Run node
make exec
rosrun <package> <node>

# Terminal 3: View topics
make exec
rostopic list
```

## 📦 Custom Configuration

### Change ROS Version

Edit `.env` file:

```bash
ROS_DISTRO=melodic  # or foxy, humble, etc.
```

Then rebuild:

```bash
make rebuild
```

### Add Extra Packages

Edit `Dockerfile`, add required packages in the `RUN apt-get install` section:

```dockerfile
RUN apt-get update && apt-get install -y \
    # ... existing packages ...
    ros-${ROS_DISTRO}-your-package \
    && rm -rf /var/lib/apt/lists/*
```

### Mount Additional Directories

Edit `Makefile` or `docker-compose.yml`, add volume mounts:

```yaml
volumes:
  - ${WORKSPACE_DIR}:/home/${USER_NAME}/catkin_ws
  - /path/on/host:/path/in/container  # Add new mount
```

## 🛡️ Notes

1. **Data Persistence**: Container's `~/catkin_ws` directory is mounted to host, data is automatically saved
2. **Container Deletion**: Containers with `--rm` flag auto-delete on exit, but mounted data is preserved
3. **Privileged Mode**: Container uses `--privileged` mode to support hardware access, be aware of security
4. **Network Mode**: Uses host network mode, container shares network stack with host

## 📚 Reference Resources

- [ROS Noetic Official Documentation](http://wiki.ros.org/noetic)
- [Docker Official Documentation](https://docs.docker.com/)
- [ROS Docker Best Practices](http://wiki.ros.org/docker/Tutorials)

## 📄 License

This project configuration follows the MIT License.

## 🤝 Contribution

Issues and Pull Requests are welcome!

---

**Happy Coding! 🚀**
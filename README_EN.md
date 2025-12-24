# ROS Noetic Docker Development Environment

A Docker-based ROS Noetic development environment configuration that supports complete containerized development workflows.

## 📋 Directory Structure

```
kudan_ws/
├── docker/                     # Docker configuration directory
│   ├── config/                  # Container configuration files
│   │   └── bashrc              # Container-specific bashrc configuration
│   ├── scripts/                # Shell scripts directory
│   │   ├── init-env.sh         # Environment initialization script
│   │   ├── docker-build.sh     # Build image script
│   │   ├── docker-run.sh       # Run container script (interactive)
│   │   ├── docker-run-detach.sh # Run container in background
│   │   ├── docker-exec.sh      # Enter container script
│   │   └── docker-stop.sh      # Stop container script
│   ├── Dockerfile              # Docker image build file
│   ├── docker-compose.yml      # Docker Compose configuration
│   ├── requirements.txt        # Python dependencies list
│   └── .env                    # Environment variables configuration
├── Makefile                    # Make commands (recommended)
├── README.md                   # Documentation (Chinese)
├── README_EN.md                # This document (English)
└── src/                        # ROS workspace source directory
```

## ✨ Features

- ✅ **Automated Configuration**: Auto-detect user information and workspace path
- ✅ **Python Dependency Management**: Support automatic installation via requirements.txt
- ✅ **Rich Shortcuts**: Pre-configured bash aliases and functions in container
- ✅ **Permission Consistency**: Container user UID/GID matches host to avoid permission issues
- ✅ **GUI Support**: Support RViz, rqt and other GUI tools (via X11 forwarding)
- ✅ **Workspace Mounting**: Host workspace syncs to container in real-time
- ✅ **Network Interconnection**: Use host network mode to simplify ROS node communication
- ✅ **Multiple Usage Methods**: Support Makefile, Shell scripts, Docker Compose

## 🚀 Quick Start

### Prerequisites

- Docker installed (version >= 19.03)
- Docker Compose installed (optional)
- Make tool (optional, recommended)

### 1. Initialize Environment Configuration (Recommended)

Automatically detect and configure environment variables:

```bash
# Using Makefile (recommended)
make init

# Or run script directly
./docker/scripts/init-env.sh
```

This command will automatically:
- Detect current username, UID, GID
- Detect workspace path
- Generate `docker/.env` configuration file
- Backup existing configuration (if exists)

**Manual Configuration (Optional)**

If not using auto-initialization, you can manually view and modify the `docker/.env` file:

```bash
# User configuration (auto-generated)
USER_NAME=duboping
USER_UID=1000
USER_GID=1000

# Docker image configuration
IMAGE_NAME=ros-kudan-dev
IMAGE_TAG=latest
CONTAINER_NAME=kudan_ws_container

# ROS version configuration
ROS_DISTRO=noetic

# Workspace path (auto-generated)
WORKSPACE_DIR=/home/duboping/public/kudan/kudan_ws
```

### 2. Configure Python Dependencies (Optional)

If you need to install additional Python packages, edit the `docker/requirements.txt` file:

```bash
# Uncomment and add required packages
numpy>=1.19.0
matplotlib>=3.3.0
opencv-python>=4.5.0
# ... add more packages
```

Dependencies will be automatically installed during image build.

### 3. Build Docker Image

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

### 4. Run Container

**Method 1: Interactive Mode (auto-remove after exit)**

```bash
# Using Makefile
make run

# Using Shell script
./docker/scripts/docker-run.sh
```

**Method 2: Background Mode**

```bash
# Using Makefile
make run-detach

# Using Shell script
./docker/scripts/docker-run-detach.sh

# Using Docker Compose
cd docker
docker-compose up -d
```

### 5. Enter Container

If the container is running in background, use the following commands to enter:

```bash
# Using Makefile
make exec

# Using Shell script
./docker/scripts/docker-exec.sh

# Using Docker Compose
cd docker
docker-compose exec ros-dev bash
```

## 📖 Detailed Usage

### Makefile Commands

View all available commands:

```bash
make help
```

Common commands:

| Command | Description |
|---------|-------------|
| `make help` | Show help information |
| `make init` | Initialize environment configuration (auto-detect system info) |
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
# Enter docker directory
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

## 🔧 Container Development

### ROS Environment

ROS environment is automatically configured in the container:

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

### Pre-configured Aliases and Shortcuts

Rich bash aliases and shortcuts are configured in the container:

**Workspace Navigation:**
```bash
cw    # cd ~/catkin_ws
cs    # cd ~/catkin_ws/src
```

**Build Commands:**
```bash
cm       # catkin_make
cb       # catkin build
remake   # Clean and rebuild
soc      # Reload environment
```

**ROS Command Aliases:**
```bash
rt       # rostopic
rn       # rosnode
rp       # rosparam
rs       # rosservice
rl       # roslaunch
rr       # rosrun
```

**Utility Functions:**
```bash
create_ros_pkg <name> [deps]  # Quickly create ROS package
find_pkg <name>               # Find package path
topic_echo <topic>            # Quick topic monitoring
```

### Install Additional Dependencies

**Install ROS Packages:**
```bash
sudo apt-get update
sudo apt-get install ros-noetic-<package-name>
```

**Use rosdep to Install Dependencies:**
```bash
cd ~/catkin_ws
rosdep install --from-paths src --ignore-src -r -y
```

**Install Python Packages:**
```bash
# Inside container
pip3 install --user <package-name>

# Or edit docker/requirements.txt before building image
```

## 🖥️ GUI Application Support

### RViz Example

```bash
# Run in container
roscore &
rviz
```

### rqt Tools

```bash
# Run in container
rqt
```

If you encounter GUI display issues, execute on the host:

```bash
xhost +local:docker
```

## 📝 FAQ

### 1. Permission Issues

**Problem**: Files created in container cannot be accessed on host

**Solution**: Ensure `USER_UID` and `USER_GID` in `.env` file match host user. Check with:

```bash
id -u  # Check UID
id -g  # Check GID
```

### 2. GUI Cannot Display

**Problem**: RViz or rqt cannot start

**Solution**: Allow Docker to access X11 on the host:

```bash
xhost +local:docker
```

If using SSH connection, enable X11 forwarding:

```bash
ssh -X user@host
```

### 3. Network Connection Issues

**Problem**: ROS nodes cannot communicate

**Solution**: Ensure container uses `--network host` mode (already set in config)

### 4. Container Name Conflict

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
# 1. Initialize environment (first time only)
make init

# 2. Build image (first time or after Dockerfile changes)
make build

# 3. Start container in background
make run-detach

# 4. Enter container
make exec

# 5. Develop inside container
cd ~/catkin_ws/src
# ... write code ...
cd ~/catkin_ws
catkin_make
source devel/setup.bash
rosrun <package> <node>

# 6. Exit container (container continues running)
exit

# 7. Re-enter when needed
make exec

# 8. Stop container when done
make stop
```

### Multi-terminal Workflow

```bash
# Terminal 1: Start roscore
make run-detach
make exec
roscore

# Terminal 2: Run nodes
make exec
rosrun <package> <node>

# Terminal 3: Monitor topics
make exec
rostopic list
```

## 📦 Custom Configuration

### Modify ROS Version

Edit `.env` file:

```bash
ROS_DISTRO=melodic  # Or foxy, humble, etc.
```

Then rebuild:

```bash
make rebuild
```

### Add Additional Packages

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

## 🛡️ Important Notes

1. **Data Persistence**: The `~/catkin_ws` directory in container is mounted to host, data is automatically saved
2. **Container Deletion**: Containers with `--rm` flag are auto-removed after exit, but mounted data persists
3. **Privileged Mode**: Container uses `--privileged` mode to support certain hardware access, be aware of security
4. **Network Mode**: Using host network mode, container shares network stack with host

## 📚 References

- [ROS Noetic Official Documentation](http://wiki.ros.org/noetic)
- [Docker Official Documentation](https://docs.docker.com/)
- [ROS Docker Best Practices](http://wiki.ros.org/docker/Tutorials)

## 📄 License

This project configuration follows MIT License.

## 🤝 Contributing

Issues and Pull Requests are welcome!

---

**Happy Coding! 🚀**

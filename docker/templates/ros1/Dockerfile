# ROS1 Noetic Development Environment
ARG ROS_DISTRO=noetic
FROM ros:${ROS_DISTRO}

# Build arg: set to "true" for Chinese apt mirror
ARG USE_CN_MIRROR=true

# Prevent interactive prompts
ENV DEBIAN_FRONTEND=noninteractive

# Set timezone
RUN ln -sf /usr/share/zoneinfo/Asia/Shanghai /etc/localtime && \
    echo "Asia/Shanghai" > /etc/timezone

# Configure apt mirror (optional, for faster downloads in China)
RUN if [ "$USE_CN_MIRROR" = "true" ]; then \
        sed -i 's|http://archive.ubuntu.com/ubuntu|https://mirrors.ustc.edu.cn/ubuntu|g' /etc/apt/sources.list && \
        sed -i 's|http://security.ubuntu.com/ubuntu|https://mirrors.ustc.edu.cn/ubuntu|g' /etc/apt/sources.list && \
        sed -i 's|http://ports.ubuntu.com/ubuntu-ports|https://mirrors.ustc.edu.cn/ubuntu-ports|g' /etc/apt/sources.list; \
    fi

# Install prerequisites and refresh ROS GPG key
RUN apt-get update && apt-get install -y curl gnupg2 ca-certificates && \
    rm -f /usr/share/keyrings/ros-archive-keyring.gpg && \
    curl -sSL https://raw.githubusercontent.com/ros/rosdistro/master/ros.key \
         -o /usr/share/keyrings/ros-archive-keyring.gpg && \
    rm -rf /var/lib/apt/lists/*

# Install system packages and ROS1 development tools
RUN apt-get update && apt-get install -y \
    vim wget htop tmux \
    build-essential cmake git curl \
    python3-pip python3-catkin-tools python3-rosdep \
    python3-rosinstall python3-rosinstall-generator python3-wstool python3-vcstool \
    bash-completion \
    ros-${ROS_DISTRO}-rqt \
    ros-${ROS_DISTRO}-rqt-common-plugins \
    ros-${ROS_DISTRO}-rviz \
    ros-${ROS_DISTRO}-message-generation \
    ros-${ROS_DISTRO}-cv-bridge \
    ros-${ROS_DISTRO}-image-transport \
    ros-${ROS_DISTRO}-pcl-conversions \
    ros-${ROS_DISTRO}-pcl-ros \
    ros-${ROS_DISTRO}-image-geometry \
    && rm -rf /var/lib/apt/lists/*

# Create user (match host UID/GID to avoid permission issues)
ARG USER_NAME=sysadmin
ARG USER_UID=1000
ARG USER_GID=1000

RUN groupadd -g ${USER_GID} ${USER_NAME} || true && \
    useradd -m -u ${USER_UID} -g ${USER_GID} -s /bin/bash ${USER_NAME} && \
    echo "${USER_NAME} ALL=(ALL) NOPASSWD:ALL" >> /etc/sudoers

USER ${USER_NAME}
WORKDIR /home/${USER_NAME}

# Install Python dependencies
COPY --chown=${USER_NAME}:${USER_NAME} docker/requirements.txt /tmp/requirements.txt
RUN pip3 install --user --no-cache-dir -r /tmp/requirements.txt || true && \
    rm /tmp/requirements.txt

# Set up workspace
RUN mkdir -p ~/workspace/src
WORKDIR /home/${USER_NAME}/workspace

# Copy custom bashrc configuration
COPY --chown=${USER_NAME}:${USER_NAME} docker/config/bashrc /home/${USER_NAME}/.bashrc_docker

# Load Docker-specific configuration on shell start
RUN echo "if [ -f ~/.bashrc_docker ]; then source ~/.bashrc_docker; fi" >> ~/.bashrc

CMD ["/bin/bash"]

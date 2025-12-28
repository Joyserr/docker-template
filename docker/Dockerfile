# 基于ROS Noetic官方镜像
ARG ROS_DISTRO=noetic
FROM ros:${ROS_DISTRO}-ros-base

# 避免交互式提示
ENV DEBIAN_FRONTEND=noninteractive

# 设置时区为中国时区
RUN ln -sf /usr/share/zoneinfo/Asia/Shanghai /etc/localtime && \
    echo "Asia/Shanghai" > /etc/timezone

# 配置国内镜像源（Ubuntu）
RUN sed -i 's|http://archive.ubuntu.com/ubuntu|https://mirrors.ustc.edu.cn/ubuntu|g' /etc/apt/sources.list && \
    sed -i 's|http://security.ubuntu.com/ubuntu|https://mirrors.ustc.edu.cn/ubuntu|g' /etc/apt/sources.list && \
    sed -i 's|http://ports.ubuntu.com/ubuntu-ports|https://mirrors.ustc.edu.cn/ubuntu-ports|g' /etc/apt/sources.list

# 临时允许不安全的仓库，先安装必要工具
RUN apt-get update --allow-insecure-repositories 2>/dev/null || apt-get update && \
    apt-get install -y --allow-unauthenticated curl gnupg2 ca-certificates 2>/dev/null || \
    apt-get install -y curl gnupg2 ca-certificates

# 配置ROS镜像源和新的GPG密钥
RUN curl -sSL https://raw.githubusercontent.com/ros/rosdistro/master/ros.key -o /usr/share/keyrings/ros-archive-keyring.gpg && \
    echo "deb [signed-by=/usr/share/keyrings/ros-archive-keyring.gpg] https://mirrors.ustc.edu.cn/ros/ubuntu focal main" > /etc/apt/sources.list.d/ros1-latest.list

# 清理并重新更新
RUN rm -rf /var/lib/apt/lists/* && apt-get clean

# 更新apt源并安装基础开发工具
RUN apt-get update && apt-get install -y \
    vim \
    wget \
    htop \
    tmux \
    build-essential \
    cmake \
    git \
    python3-pip \
    python3-catkin-tools \
    python3-rosdep \
    python3-rosinstall \
    python3-rosinstall-generator \
    python3-wstool \
    python3-vcstool \
    ros-${ROS_DISTRO}-rqt \
    ros-${ROS_DISTRO}-rqt-common-plugins \
    ros-${ROS_DISTRO}-rviz \
    ros-${ROS_DISTRO}-message-generation \
    ros-${ROS_DISTRO}-cv-bridge \
    ros-${ROS_DISTRO}-image-transport \
    ros-${ROS_DISTRO}-pcl-conversions \
    ros-${ROS_DISTRO}-pcl-ros \
    ros-${ROS_DISTRO}-image-geometry \
    bash-completion \
    && rm -rf /var/lib/apt/lists/*

# 创建用户（与主机用户保持一致，避免权限问题）
ARG USER_NAME=sysadmin
ARG USER_UID=1000
ARG USER_GID=1000

RUN groupadd -g ${USER_GID} ${USER_NAME} || true && \
    useradd -m -u ${USER_UID} -g ${USER_GID} -s /bin/bash ${USER_NAME} && \
    echo "${USER_NAME} ALL=(ALL) NOPASSWD:ALL" >> /etc/sudoers

# 切换到用户
USER ${USER_NAME}
WORKDIR /home/${USER_NAME}

# 安装 Python 依赖（在创建工作空间之前）
COPY --chown=${USER_NAME}:${USER_NAME} requirements.txt /tmp/requirements.txt
RUN pip3 install --user --no-cache-dir -r /tmp/requirements.txt || true && \
    rm /tmp/requirements.txt

# 设置ROS工作空间
RUN mkdir -p ~/catkin_ws/src
WORKDIR /home/${USER_NAME}/catkin_ws

# 复制自定义 bashrc 配置
COPY --chown=${USER_NAME}:${USER_NAME} config/bashrc /home/${USER_NAME}/.bashrc_docker

# 配置ROS环境（加载 Docker 专用配置）
RUN echo "# Load Docker-specific ROS configuration" >> ~/.bashrc && \
    echo "if [ -f ~/.bashrc_docker ]; then" >> ~/.bashrc && \
    echo "    source ~/.bashrc_docker" >> ~/.bashrc && \
    echo "fi" >> ~/.bashrc

# 初始化rosdep
# RUN sudo rosdep init || true && \
#     rosdep update

# 默认启动bash
CMD ["/bin/bash"]

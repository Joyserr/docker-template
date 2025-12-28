#!/bin/bash
# Docker容器运行脚本（交互式）

set -e

# 加载公共函数库
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/../utils/common.sh"

# 加载环境变量
load_env_vars

# 获取Docker目录
DOCKER_DIR=$(get_docker_dir)

# 允许X11转发
xhost +local:docker > /dev/null 2>&1 || true

print_title "启动 ROS Noetic Docker 容器"
echo "容器名称: ${CONTAINER_NAME}"
echo "工作空间: ${WORKSPACE_DIR}"
echo ""

# 运行容器
docker run -it --rm \
    --name ${CONTAINER_NAME} \
    --network host \
    --privileged \
    -v ${WORKSPACE_DIR}:/home/${USER_NAME}/catkin_ws \
    -v ${WORKSPACE_DIR}/docker/config/bashrc:/home/${USER_NAME}/.bashrc_docker:ro \
    -v /tmp/.X11-unix:/tmp/.X11-unix \
    -e DISPLAY=${DISPLAY} \
    -e QT_X11_NO_MITSHM=1 \
    ${IMAGE_NAME}:${IMAGE_TAG}

echo ""
echo "容器已退出"

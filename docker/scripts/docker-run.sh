#!/bin/bash
# Docker容器运行脚本（交互式）

set -e

# 脚本目录
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
DOCKER_DIR="$(dirname "$SCRIPT_DIR")"

# 加载环境变量
if [ -f "$DOCKER_DIR/.env" ]; then
    export $(cat "$DOCKER_DIR/.env" | grep -v '^#' | xargs)
else
    echo "错误: 未找到 $DOCKER_DIR/.env 文件"
    exit 1
fi

# 允许X11转发
xhost +local:docker > /dev/null 2>&1 || true

echo "=========================================="
echo "启动 ROS Noetic Docker 容器"
echo "=========================================="
echo "容器名称: ${CONTAINER_NAME}"
echo "工作空间: ${WORKSPACE_DIR}"
echo "=========================================="
echo ""

# 运行容器
docker run -it --rm \
    --name ${CONTAINER_NAME} \
    --network host \
    --privileged \
    -v ${WORKSPACE_DIR}:/home/${USER_NAME}/catkin_ws \
    -v /tmp/.X11-unix:/tmp/.X11-unix \
    -e DISPLAY=${DISPLAY} \
    -e QT_X11_NO_MITSHM=1 \
    ${IMAGE_NAME}:${IMAGE_TAG}

echo ""
echo "容器已退出"

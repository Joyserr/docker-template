#!/bin/bash
# Docker容器后台运行脚本

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
echo "后台启动 ROS Noetic Docker 容器"
echo "=========================================="
echo "容器名称: ${CONTAINER_NAME}"
echo "工作空间: ${WORKSPACE_DIR}"
echo "=========================================="
echo ""

# 检查容器是否已经在运行
if docker ps -a --format '{{.Names}}' | grep -q "^${CONTAINER_NAME}$"; then
    echo "警告: 容器 ${CONTAINER_NAME} 已存在"
    read -p "是否删除现有容器并重新启动? (y/n) " -n 1 -r
    echo
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        docker stop ${CONTAINER_NAME} 2>/dev/null || true
        docker rm ${CONTAINER_NAME} 2>/dev/null || true
    else
        echo "操作已取消"
        exit 0
    fi
fi

# 后台运行容器
docker run -d \
    --name ${CONTAINER_NAME} \
    --network host \
    --privileged \
    -v ${WORKSPACE_DIR}:/home/${USER_NAME}/catkin_ws \
    -v ${WORKSPACE_DIR}/docker/config/bashrc:/home/${USER_NAME}/.bashrc_docker:ro \
    -v /tmp/.X11-unix:/tmp/.X11-unix \
    -e DISPLAY=${DISPLAY} \
    -e QT_X11_NO_MITSHM=1 \
    ${IMAGE_NAME}:${IMAGE_TAG} \
    tail -f /dev/null

echo ""
echo "=========================================="
echo "容器已在后台运行"
echo "=========================================="
echo "使用以下命令进入容器:"
echo "  ./docker/scripts/docker-exec.sh"
echo "或使用 make:"
echo "  make exec"
echo "=========================================="

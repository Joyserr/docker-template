#!/bin/bash
# Docker镜像构建脚本

set -e

# 脚本目录
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
DOCKER_DIR="$(dirname "$SCRIPT_DIR")"
PROJECT_ROOT="$(dirname "$DOCKER_DIR")"

# 加载环境变量
if [ -f "$DOCKER_DIR/.env" ]; then
    export $(cat "$DOCKER_DIR/.env" | grep -v '^#' | xargs)
else
    echo "错误: 未找到 $DOCKER_DIR/.env 文件"
    exit 1
fi

echo "=========================================="
echo "ROS Noetic Docker 镜像构建"
echo "=========================================="
echo "镜像名称: ${IMAGE_NAME}:${IMAGE_TAG}"
echo "ROS版本:  ${ROS_DISTRO}"
echo "用户信息: ${USER_NAME} (UID=${USER_UID}, GID=${USER_GID})"
echo "=========================================="
echo ""

# 构建镜像
docker build \
    --build-arg ROS_DISTRO=${ROS_DISTRO} \
    --build-arg USER_NAME=${USER_NAME} \
    --build-arg USER_UID=${USER_UID} \
    --build-arg USER_GID=${USER_GID} \
    -f "$DOCKER_DIR/Dockerfile" \
    -t ${IMAGE_NAME}:${IMAGE_TAG} \
    "$DOCKER_DIR"

echo ""
echo "=========================================="
echo "镜像构建完成！"
echo "=========================================="
echo "使用以下命令运行容器:"
echo "  ./docker/scripts/docker-run.sh"
echo "或使用 make:"
echo "  make run"
echo "=========================================="

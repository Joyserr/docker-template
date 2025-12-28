#!/bin/bash
# ========================================
# 通用Docker容器运行脚本（后台模式）
# ========================================

# 获取脚本所在目录
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd "$SCRIPT_DIR/../../.." && pwd)"

# 加载公共函数
source "$SCRIPT_DIR/../utils/common.sh"

# 加载环境变量
ENV_FILE="$PROJECT_ROOT/docker/config/.env"
if [ -f "$ENV_FILE" ]; then
    source "$ENV_FILE"
else
    echo "错误: 找不到配置文件 $ENV_FILE"
    echo "请先运行 'make init' 初始化环境"
    exit 1
fi

# 设置默认值
USER_NAME=${USER_NAME:-$(whoami)}
USER_UID=${USER_UID:-$(id -u)}
USER_GID=${USER_GID:-$(id -g)}
IMAGE_NAME=${IMAGE_NAME:-my-dev-image}
IMAGE_TAG=${IMAGE_TAG:-latest}
CONTAINER_NAME=${CONTAINER_NAME:-my_dev_container}
WORKSPACE_DIR=${WORKSPACE_DIR:-$PROJECT_ROOT}

# 显示运行信息
echo "========================================="
echo "Docker容器运行（后台模式）"
echo "========================================="
echo ""
echo "镜像名称: ${IMAGE_NAME}:${IMAGE_TAG}"
echo "容器名称: ${CONTAINER_NAME}"
echo "用户信息: ${USER_NAME} (UID=${USER_UID}, GID=${USER_GID})"
echo "工作空间: ${WORKSPACE_DIR}"
echo ""

# 检查镜像是否存在
if ! docker images --format '{{.Repository}}:{{.Tag}}' | grep -q "^${IMAGE_NAME}:${IMAGE_TAG}$"; then
    echo "错误: 镜像 ${IMAGE_NAME}:${IMAGE_TAG} 不存在"
    echo "请先运行 'make build' 构建镜像"
    exit 1
fi

# 检查容器是否已存在
if docker ps -a --format '{{.Names}}' | grep -q "^${CONTAINER_NAME}$"; then
    echo "警告: 容器 ${CONTAINER_NAME} 已存在，正在删除..."
    docker rm -f ${CONTAINER_NAME} > /dev/null 2>&1 || true
fi

# 启用X11转发（用于GUI应用）
xhost +local:docker > /dev/null 2>&1 || true

# 运行容器（后台模式）
echo "启动容器（后台模式）..."
docker run -d \
    --name ${CONTAINER_NAME} \
    --network host \
    --user ${USER_UID}:${USER_GID} \
    -e DISPLAY=$DISPLAY \
    -v /tmp/.X11-unix:/tmp/.X11-unix:rw \
    -v ${WORKSPACE_DIR}:/home/${USER_NAME}/workspace:rw \
    -w /home/${USER_NAME}/workspace \
    ${IMAGE_NAME}:${IMAGE_TAG}

# 检查容器是否成功启动
if [ $? -eq 0 ]; then
    echo ""
    echo "========================================="
    echo "✓ 容器已启动（后台运行）"
    echo "========================================="
    echo ""
    echo "查看容器日志:"
    echo "  make logs"
    echo ""
    echo "进入容器:"
    echo "  make exec CMD='bash'"
    echo ""
    echo "停止容器:"
    echo "  make stop"
    echo ""
else
    echo ""
    echo "========================================="
    echo "✗ 容器启动失败"
    echo "========================================="
    exit 1
fi

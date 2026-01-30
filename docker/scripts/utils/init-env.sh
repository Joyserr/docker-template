#!/bin/bash
# 初始化环境变量脚本

set -e

# 加载公共函数库
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/common.sh"

# 获取目录路径
DOCKER_DIR=$(get_docker_dir)
PROJECT_ROOT=$(get_project_root)
ENV_FILE="$DOCKER_DIR/config/.env"

print_title "Docker 环境初始化"

# 自动检测用户信息
DETECTED_USER=$(whoami)
DETECTED_UID=$(id -u)
DETECTED_GID=$(id -g)
DETECTED_WORKSPACE=$(cd "$PROJECT_ROOT" && pwd)

echo "检测到的系统信息："
echo "  用户名: $DETECTED_USER"
echo "  UID: $DETECTED_UID"
echo "  GID: $DETECTED_GID"
echo "  工作空间: $DETECTED_WORKSPACE"
echo ""

# 检查是否已存在 .env 文件
if [ -f "$ENV_FILE" ]; then
    echo "检测到已存在的 .env 文件"
    read -p "是否覆盖现有配置？(y/N) " -n 1 -r
    echo
    if [[ ! $REPLY =~ ^[Yy]$ ]]; then
        echo "保留现有配置，退出初始化"
        exit 0
    fi
    # 备份现有文件
    cp "$ENV_FILE" "$ENV_FILE.backup.$(date +%Y%m%d_%H%M%S)"
    echo "已备份原配置文件"
fi

# 生成 .env 文件
cat > "$ENV_FILE" << EOF
# ========================================
# Docker 镜像配置文件 (由 init-env.sh 自动生成)
# ========================================

# 用户配置（与主机用户保持一致，避免权限问题）
USER_NAME=$DETECTED_USER
USER_UID=$DETECTED_UID
USER_GID=$DETECTED_GID

# Docker 镜像配置
IMAGE_NAME=my-dev-image
IMAGE_TAG=latest
CONTAINER_NAME=my_dev_container

# ROS 配置 (如果使用 ROS 模板)
ROS_DISTRO=noetic

# GUI 支持
ENABLE_GUI=true

# GPU 支持 (需要 nvidia-docker2)
ENABLE_GPU=false

# 提升权限 (危险：仅在确实需要时启用)
ENABLE_PRIVILEGED=false

# 挂载 Docker Socket
MOUNT_DOCKER_SOCK=false

# 工作空间目录 (挂载到容器中的目录)
WORKSPACE_DIR=$DETECTED_WORKSPACE

# 容器内的工作目录名称 (挂载到 /home/$USER_NAME/$CONTAINER_WORKSPACE)
CONTAINER_WORKSPACE=workspace

# 共享内存大小
SHM_SIZE=2g

# IPC 模式
IPC_MODE=host
EOF

echo ""
echo "=========================================="
echo "环境配置文件已生成: $ENV_FILE"
echo "=========================================="
echo ""
echo "配置内容："
cat "$ENV_FILE"
echo ""
echo "=========================================="
echo "初始化完成！"
echo "=========================================="
echo ""
echo "下一步："
echo "  1. 运行 'make build' 构建Docker镜像"
echo "  2. 运行 'make run' 启动容器"
echo "=========================================="

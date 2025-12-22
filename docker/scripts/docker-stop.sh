#!/bin/bash
# 停止并删除Docker容器

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

echo "=========================================="
echo "停止容器: ${CONTAINER_NAME}"
echo "=========================================="
echo ""

# 停止并删除容器
docker stop ${CONTAINER_NAME} 2>/dev/null || true
docker rm ${CONTAINER_NAME} 2>/dev/null || true

echo "容器已停止并删除"

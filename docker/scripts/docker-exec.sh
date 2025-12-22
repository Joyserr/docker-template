#!/bin/bash
# 进入运行中的Docker容器

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

# 检查容器是否在运行
if ! docker ps --format '{{.Names}}' | grep -q "^${CONTAINER_NAME}$"; then
    echo "错误: 容器 ${CONTAINER_NAME} 未运行"
    echo "请先运行: ./docker/scripts/docker-run-detach.sh"
    exit 1
fi

echo "=========================================="
echo "进入容器: ${CONTAINER_NAME}"
echo "=========================================="
echo ""

# 进入容器
docker exec -it ${CONTAINER_NAME} /bin/bash

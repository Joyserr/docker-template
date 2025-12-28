#!/bin/bash
# 停止并删除Docker容器

set -e

# 加载公共函数库
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/../utils/common.sh"

# 加载环境变量
load_env_vars

print_title "停止容器: ${CONTAINER_NAME}"
echo ""

# 停止并删除容器
docker stop ${CONTAINER_NAME} 2>/dev/null || true
docker rm ${CONTAINER_NAME} 2>/dev/null || true

echo "容器已停止并删除"

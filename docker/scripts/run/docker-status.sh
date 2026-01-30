#!/bin/bash
# ========================================
# 查看容器状态
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
    print_error "找不到配置文件 $ENV_FILE"
    exit 1
fi

# 设置默认值
CONTAINER_NAME=${CONTAINER_NAME:-my_dev_container}

print_title "容器状态"
echo ""

# 查看容器状态
if docker ps -a --filter "name=${CONTAINER_NAME}" --format "{{.Names}}" | grep -q "^${CONTAINER_NAME}$"; then
    docker ps -a --filter "name=${CONTAINER_NAME}" --format "table {{.Names}}\t{{.Status}}\t{{.Image}}"
else
    print_info "未找到容器: ${CONTAINER_NAME}"
fi

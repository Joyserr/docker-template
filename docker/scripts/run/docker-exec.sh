#!/bin/bash
# ========================================
# 在运行中的Docker容器中执行命令
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
    print_info "请先运行 'make init' 初始化环境"
    exit 1
fi

# 设置默认值
CONTAINER_NAME=${CONTAINER_NAME:-my_dev_container}
CMD=${1:-bash}

# 检查容器是否运行
if ! docker ps --format '{{.Names}}' | grep -q "^${CONTAINER_NAME}$"; then
    print_error "容器 ${CONTAINER_NAME} 未运行"
    print_info "请先运行 'make run' 启动容器"
    exit 1
fi

# 执行命令
print_info "在容器 ${CONTAINER_NAME} 中执行命令: ${CMD}"
docker exec -it "${CONTAINER_NAME}" ${CMD}

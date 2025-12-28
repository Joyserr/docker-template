#!/bin/bash
# 查看容器日志

set -e

# 加载公共函数库
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/../utils/common.sh"

# 加载环境变量
load_env_vars

print_title "查看容器日志: ${CONTAINER_NAME}"
echo ""

# 检查容器是否存在
if ! check_docker_container_exists "${CONTAINER_NAME}"; then
    print_error "容器 ${CONTAINER_NAME} 不存在"
    exit 1
fi

# 查看日志
docker logs -f ${CONTAINER_NAME}

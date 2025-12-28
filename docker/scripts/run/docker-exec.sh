#!/bin/bash
# 进入运行中的Docker容器

set -e

# 加载公共函数库
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/../utils/common.sh"

# 加载环境变量
load_env_vars

# 检查容器是否在运行
if ! check_docker_container "${CONTAINER_NAME}"; then
    print_error "容器 ${CONTAINER_NAME} 未运行"
    print_info "请先运行: ./docker/scripts/run/docker-run-detach.sh"
    exit 1
fi

print_title "进入容器: ${CONTAINER_NAME}"
echo ""

# 进入容器
docker exec -it ${CONTAINER_NAME} /bin/bash

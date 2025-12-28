#!/bin/bash
# 清理容器和镜像

set -e

# 加载公共函数库
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/../utils/common.sh"

# 加载环境变量
load_env_vars

print_title "清理容器和镜像"
echo ""

# 停止并删除容器
if check_docker_container_exists "${CONTAINER_NAME}"; then
    print_info "停止容器: ${CONTAINER_NAME}"
    docker stop ${CONTAINER_NAME} 2>/dev/null || true
    docker rm ${CONTAINER_NAME} 2>/dev/null || true
fi

# 删除镜像
print_info "删除镜像: ${IMAGE_NAME}:${IMAGE_TAG}"
docker rmi ${IMAGE_NAME}:${IMAGE_TAG} 2>/dev/null || true

print_success "清理完成"

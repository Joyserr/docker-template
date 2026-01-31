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
if ! load_env_vars; then
    exit 1
fi

# 设置默认值
USER_NAME=${USER_NAME:-$(whoami)}
USER_UID=${USER_UID:-$(id -u)}
USER_GID=${USER_GID:-$(id -g)}
IMAGE_NAME=${IMAGE_NAME:-my-dev-image}
IMAGE_TAG=${IMAGE_TAG:-latest}
CONTAINER_NAME=${CONTAINER_NAME:-my_dev_container}
WORKSPACE_DIR=${WORKSPACE_DIR:-$(get_project_root)}
CONTAINER_WORKSPACE=${CONTAINER_WORKSPACE:-workspace}

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

# macOS 与 Linux 的网络与权限选项
DOCKER_RUN_FLAGS=()

# 基本运行参数
DOCKER_RUN_FLAGS+=(-d --name "${CONTAINER_NAME}" --user "${USER_UID}:${USER_GID}" -e DISPLAY="$DISPLAY" -w "/home/${USER_NAME}/${CONTAINER_WORKSPACE}" -v "${WORKSPACE_DIR}:/home/${USER_NAME}/${CONTAINER_WORKSPACE}:rw")

# 根据主机系统选择网络模式与端口映射
if [[ "$(uname -s)" == "Darwin" ]]; then
    echo "Detected macOS: 使用端口映射替代 --network host"
    EXTRA_PORTS="${EXTRA_PORTS:--p 1883:1883 -p 9001:9001}"
    read -r -a PORT_TOKENS <<< "${EXTRA_PORTS}"
    for ((i=0;i<${#PORT_TOKENS[@]};i+=2)); do
        DOCKER_RUN_FLAGS+=("${PORT_TOKENS[i]}" "${PORT_TOKENS[i+1]}")
    done
    DOCKER_RUN_FLAGS+=(--add-host "host.docker.internal:host-gateway")
else
    DOCKER_RUN_FLAGS+=(--network host)
fi

# 挂载 X11 socket
DOCKER_RUN_FLAGS+=(-v /tmp/.X11-unix:/tmp/.X11-unix:rw)

# 允许额外自定义参数
if [[ -n "${EXTRA_DOCKER_ARGS:-}" ]]; then
    read -r -a EXTRA_TOKENS <<< "${EXTRA_DOCKER_ARGS}"
    for t in "${EXTRA_TOKENS[@]}"; do
        DOCKER_RUN_FLAGS+=("${t}")
    done
fi

# 最后追加镜像
DOCKER_RUN_FLAGS+=("${IMAGE_NAME}:${IMAGE_TAG}")

# 运行容器（后台模式）
echo "启动容器（后台模式）..."
echo "docker run ${DOCKER_RUN_FLAGS[*]}"
docker run "${DOCKER_RUN_FLAGS[@]}"

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

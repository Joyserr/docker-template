#!/bin/bash
# ========================================
# 通用Docker容器运行脚本（交互式）
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
echo "Docker容器运行"
echo "========================================="
echo ""
echo "镜像名称: ${IMAGE_NAME}:${IMAGE_TAG}"
echo "容器名称: ${CONTAINER_NAME}"
echo "用户信息: ${USER_NAME} (UID=${USER_UID}, GID=${USER_GID})"
echo "工作空间: ${WORKSPACE_DIR} -> /home/${USER_NAME}/${CONTAINER_WORKSPACE}"
echo ""

# 检查镜像是否存在
if ! docker images --format '{{.Repository}}:{{.Tag}}' | grep -q "^${IMAGE_NAME}:${IMAGE_TAG}$"; then
    echo "错误: 镜像 ${IMAGE_NAME}:${IMAGE_TAG} 不存在"
    echo "请先运行 'make build' 构建镜像"
    exit 1
fi

# 检查容器是否已存在
if docker ps -a --format '{{.Names}}' | grep -q "^${CONTAINER_NAME}$"; then
    echo "警告: 容器 ${CONTAINER_NAME} 已存在，正在删除..."
    docker rm -f ${CONTAINER_NAME} > /dev/null 2>&1 || true
fi

# 启用X11转发（用于GUI应用）
xhost +local:docker > /dev/null 2>&1 || true

# macOS 与 Linux 的网络与权限选项
# 在 macOS 上 Docker Desktop 不支持 --network host，因此使用端口映射和 host.docker.internal 访问主机服务
DOCKER_RUN_FLAGS=()

# 基本运行参数
DOCKER_RUN_FLAGS+=(--rm -it --name "${CONTAINER_NAME}" --user "${USER_UID}:${USER_GID}" -e DISPLAY="$DISPLAY" -w "/home/${USER_NAME}/${CONTAINER_WORKSPACE}" -v "${WORKSPACE_DIR}:/home/${USER_NAME}/${CONTAINER_WORKSPACE}:rw")

# 根据主机系统选择网络模式与端口映射（可在 .env 中通过 EXTRA_PORTS 覆盖）
if [[ "$(uname -s)" == "Darwin" ]]; then
    echo "Detected macOS: 使用端口映射替代 --network host（请确保使用 host.docker.internal 访问宿主机服务）"
    EXTRA_PORTS="${EXTRA_PORTS:--p 1883:1883 -p 9001:9001}"
    read -r -a PORT_TOKENS <<< "${EXTRA_PORTS}"
    for ((i=0;i<${#PORT_TOKENS[@]};i+=2)); do
        DOCKER_RUN_FLAGS+=("${PORT_TOKENS[i]}" "${PORT_TOKENS[i+1]}")
    done
    # 将 host.docker.internal 映射到容器（host-gateway 兼容时更稳定）
    DOCKER_RUN_FLAGS+=(--add-host "host.docker.internal:host-gateway")
else
    # Linux 下直接使用 host 网络以简化主机服务访问
    DOCKER_RUN_FLAGS+=(--network host)
fi

# 可选挂载 docker.sock（允许容器内使用 docker CLI 管理宿主上的容器）
if [[ "${MOUNT_DOCKER_SOCK:-false}" == "true" ]]; then
    DOCKER_RUN_FLAGS+=(-v /var/run/docker.sock:/var/run/docker.sock:rw)
fi

# 可选启用 GPU
if [[ "${ENABLE_GPU:-false}" == "true" ]]; then
    DOCKER_RUN_FLAGS+=(--gpus all)
fi

# 可选提升权限（危险：仅在确实需要时启用）
if [[ "${ENABLE_PRIVILEGED:-false}" == "true" ]]; then
    DOCKER_RUN_FLAGS+=(--privileged)
fi

# 额外的 capability，可以在 .env 设置 EXTRA_CAPS="NET_ADMIN SYS_PTRACE"
if [[ -n "${EXTRA_CAPS:-}" ]]; then
    for cap in ${EXTRA_CAPS}; do
        DOCKER_RUN_FLAGS+=(--cap-add "${cap}")
    done
fi

# IPC 和 /dev/shm
DOCKER_RUN_FLAGS+=(--shm-size "${SHM_SIZE:-2g}" --ipc "${IPC_MODE:-host}")

# 挂载 X11 socket（在 Linux 上有效；macOS 请使用 XQuartz + host.docker.internal 设置）
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

# 提示与运行
echo "启动容器..."
echo "docker run ${DOCKER_RUN_FLAGS[*]}"
docker run "${DOCKER_RUN_FLAGS[@]}"

echo ""
echo "========================================="
echo "容器已退出"
echo "========================================="

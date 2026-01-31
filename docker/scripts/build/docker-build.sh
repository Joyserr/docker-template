#!/bin/bash
# ========================================
# 通用Docker镜像构建脚本
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
    echo "错误: 找不到配置文件 $ENV_FILE"
    echo "请先运行 'make init' 初始化环境"
    exit 1
fi

# 设置默认值
USER_NAME=${USER_NAME:-$(whoami)}
USER_UID=${USER_UID:-$(id -u)}
USER_GID=${USER_GID:-$(id -g)}
IMAGE_NAME=${IMAGE_NAME:-my-dev-image}
IMAGE_TAG=${IMAGE_TAG:-latest}
CONTAINER_NAME=${CONTAINER_NAME:-my_dev_container}
WORKSPACE_DIR=${WORKSPACE_DIR:-$PROJECT_ROOT}

# Dockerfile路径
DOCKERFILE="$PROJECT_ROOT/docker/Dockerfile"

# 检查Dockerfile是否存在
if [ ! -f "$DOCKERFILE" ]; then
    echo "错误: 找不到 Dockerfile: $DOCKERFILE"
    echo "请创建 Dockerfile 或参考 docker/templates/ 目录下的示例"
    exit 1
fi

# 显示构建信息
echo "========================================="
echo "Docker镜像构建"
echo "========================================="
echo ""
echo "镜像名称: ${IMAGE_NAME}:${IMAGE_TAG}"
echo "容器名称: ${CONTAINER_NAME}"
echo "用户信息: ${USER_NAME} (UID=${USER_UID}, GID=${USER_GID})"
echo "工作空间: ${WORKSPACE_DIR}"
echo "Dockerfile: ${DOCKERFILE}"
echo ""

# 构建镜像
echo "开始构建镜像..."
docker build \
    --build-arg USER_NAME="${USER_NAME}" \
    --build-arg USER_UID="${USER_UID}" \
    --build-arg USER_GID="${USER_GID}" \
    --build-arg WORKSPACE_DIR="${WORKSPACE_DIR}" \
    -t "${IMAGE_NAME}:${IMAGE_TAG}" \
    -f "${DOCKERFILE}" \
    "$PROJECT_ROOT"

# 检查构建结果
if [ $? -eq 0 ]; then
    echo ""
    echo "========================================="
    echo "✓ 镜像构建成功！"
    echo "========================================="
    echo ""
    echo "运行以下命令启动容器:"
    echo "  make run"
    echo ""
    echo "或使用Docker命令:"
    echo "  docker run -it --rm \\"
    echo "    --name ${CONTAINER_NAME} \\"
    echo "    -v ${WORKSPACE_DIR}:/home/${USER_NAME}/workspace \\"
    echo "    ${IMAGE_NAME}:${IMAGE_TAG}"
    echo ""
else
    echo ""
    echo "========================================="
    echo "✗ 镜像构建失败"
    echo "========================================="
    exit 1
fi

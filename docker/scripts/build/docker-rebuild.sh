#!/bin/bash
# 清理并重新构建镜像

set -e

# 加载公共函数库
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/../utils/common.sh"

# 加载环境变量
load_env_vars

print_title "清理并重新构建镜像"
echo ""

# 调用清理脚本
"$SCRIPT_DIR/docker-clean.sh"

echo ""

# 调用构建脚本
"$SCRIPT_DIR/../build/docker-build.sh"

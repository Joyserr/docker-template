#!/bin/bash
# Docker脚本公共函数库
# 提供环境变量加载、路径解析、颜色输出、Docker状态检查等公共功能

# 颜色定义
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# 打印信息函数
print_info() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

print_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

print_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

# 获取脚本目录
get_script_dir() {
    echo "$(cd "$(dirname "${BASH_SOURCE[1]}")" && pwd)"
}

# 获取Docker目录
get_docker_dir() {
    # 从脚本所在目录开始向上查找docker目录
    local script_dir="$(cd "$(dirname "${BASH_SOURCE[1]}")" && pwd)"
    local current_dir="$script_dir"
    
    # 向上查找docker目录
    while [ "$current_dir" != "/" ]; do
        if [ -d "$current_dir/docker" ]; then
            echo "$current_dir/docker"
            return 0
        elif [[ "$current_dir" == */docker/scripts ]]; then
            # 如果当前目录是docker/scripts，直接返回父目录
            echo "$(dirname "$current_dir")"
            return 0
        elif [[ "$current_dir" == */docker/scripts/run ]] || [[ "$current_dir" == */docker/scripts/build ]] || [[ "$current_dir" == */docker/scripts/utils ]]; then
            # 如果在docker/scripts的子目录下，返回docker目录
            echo "$(dirname "$(dirname "$current_dir")")"
            return 0
        fi
        current_dir="$(dirname "$current_dir")"
    done
    
    # 如果找不到，使用相对路径
    echo "$(dirname "$(dirname "$script_dir")")"
}

# 获取项目根目录
get_project_root() {
    local docker_dir="$(get_docker_dir)"
    echo "$(dirname "$docker_dir")"
}

# 加载环境变量
load_env_vars() {
    local env_file="$1"
    
    if [ -z "$env_file" ]; then
        local docker_dir="$(get_docker_dir)"
        env_file="$docker_dir/config/.env"
    fi
    
    if [ -f "$env_file" ]; then
        export $(cat "$env_file" | grep -v '^#' | xargs)
        return 0
    else
        print_error "未找到环境变量文件: $env_file"
        return 1
    fi
}

# 加载多架构环境变量
load_multiarch_env_vars() {
    local env_file="$1"
    
    if [ -z "$env_file" ]; then
        local docker_dir="$(get_docker_dir)"
        env_file="$docker_dir/config/.env.multiarch"
    fi
    
    if [ -f "$env_file" ]; then
        export $(cat "$env_file" | grep -v '^#' | xargs)
        return 0
    else
        print_error "未找到多架构环境变量文件: $env_file"
        return 1
    fi
}

# 检查Docker容器是否在运行
check_docker_container() {
    local container_name="$1"
    
    if [ -z "$container_name" ]; then
        print_error "未指定容器名称"
        return 1
    fi
    
    if docker ps --format '{{.Names}}' | grep -q "^${container_name}$"; then
        return 0
    else
        return 1
    fi
}

# 检查Docker容器是否存在（包括已停止的容器）
check_docker_container_exists() {
    local container_name="$1"
    
    if [ -z "$container_name" ]; then
        print_error "未指定容器名称"
        return 1
    fi
    
    if docker ps -a --format '{{.Names}}' | grep -q "^${container_name}$"; then
        return 0
    else
        return 1
    fi
}

# 打印分隔线
print_separator() {
    local char="${1:-=}"
    local length="${2:-40}"
    printf '%*s\n' "$length" '' | tr ' ' "$char"
}

# 打印标题
print_title() {
    local title="$1"
    echo ""
    print_separator
    echo "$title"
    print_separator
    echo ""
}

# 检查命令是否存在
check_command() {
    local cmd="$1"
    if command -v "$cmd" >/dev/null 2>&1; then
        return 0
    else
        return 1
    fi
}

# 检查Docker是否可用
check_docker() {
    if ! check_command docker; then
        print_error "Docker未安装或不在PATH中"
        return 1
    fi
    
    if ! docker info >/dev/null 2>&1; then
        print_error "Docker守护进程未运行"
        return 1
    fi
    
    return 0
}

# 检查Docker Buildx是否可用
check_buildx() {
    if ! check_docker; then
        return 1
    fi
    
    if ! docker buildx version >/dev/null 2>&1; then
        print_error "Docker Buildx未安装或不可用"
        print_info "请确保使用Docker 19.03+版本，并启用Buildx实验性功能"
        return 1
    fi
    
    return 0
}

# 确认操作
confirm_action() {
    local message="$1"
    local default="${2:-n}"
    
    if [ "$default" = "y" ]; then
        read -p "$message (Y/n) " -n 1 -r
        echo
        [[ ! $REPLY =~ ^[Nn]$ ]]
    else
        read -p "$message (y/N) " -n 1 -r
        echo
        [[ $REPLY =~ ^[Yy]$ ]]
    fi
}

# 获取当前系统架构
get_system_arch() {
    case "$(uname -m)" in
        x86_64)
            echo "amd64"
            ;;
        aarch64)
            echo "arm64"
            ;;
        armv7l)
            echo "armv7"
            ;;
        *)
            echo "unknown"
            ;;
    esac
}

# 检查文件是否为空
is_file_empty() {
    local file="$1"
    if [ ! -f "$file" ]; then
        return 1
    fi
    [ ! -s "$file" ]
}

# 备份文件
backup_file() {
    local file="$1"
    local backup_suffix="${2:-.backup.$(date +%Y%m%d_%H%M%S)}"
    
    if [ ! -f "$file" ]; then
        print_warning "文件不存在，无法备份: $file"
        return 1
    fi
    
    local backup_file="${file}${backup_suffix}"
    cp "$file" "$backup_file"
    print_info "已备份文件: $file -> $backup_file"
    return 0
}

# 创建目录（如果不存在）
ensure_dir() {
    local dir="$1"
    if [ ! -d "$dir" ]; then
        mkdir -p "$dir"
        print_info "已创建目录: $dir"
    fi
}

# 导出所有函数供其他脚本使用
export -f print_info
export -f print_success
export -f print_warning
export -f print_error
export -f get_script_dir
export -f get_docker_dir
export -f get_project_root
export -f load_env_vars
export -f load_multiarch_env_vars
export -f check_docker_container
export -f check_docker_container_exists
export -f print_separator
export -f print_title
export -f check_command
export -f check_docker
export -f check_buildx
export -f confirm_action
export -f get_system_arch
export -f is_file_empty
export -f backup_file
export -f ensure_dir

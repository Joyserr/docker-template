#!/bin/bash
# 平台选择脚本 - 交互式选择要构建的目标平台

set -e

# 脚本目录
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
DOCKER_DIR="$(dirname "$SCRIPT_DIR")"

# 颜色输出
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
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

# 可用平台列表
declare -A PLATFORMS=(
    ["1"]="linux/amd64"
    ["2"]="linux/arm64"
    ["3"]="linux/arm/v7"
    ["4"]="linux/riscv64"
)

# 平台描述
declare -A PLATFORM_DESC=(
    ["1"]="Intel/AMD 64位 (x86_64)"
    ["2"]="ARM 64位 (aarch64)"
    ["3"]="ARM 32位 (armv7)"
    ["4"]="RISC-V 64位"
)

# 显示标题
show_header() {
    clear
    echo -e "${CYAN}========================================${NC}"
    echo -e "${CYAN}  Docker多架构构建平台选择${NC}"
    echo -e "${CYAN}========================================${NC}"
    echo ""
}

# 显示当前系统信息
show_system_info() {
    print_info "当前系统信息:"
    echo "  操作系统: $(uname -s)"
    echo "  架构: $(uname -m)"
    echo "  Docker版本: $(docker --version 2>/dev/null || echo '未安装')"
    echo ""
}

# 显示可用平台
show_platforms() {
    print_info "可用目标平台:"
    echo ""
    
    for key in "${!PLATFORMS[@]}"; do
        echo -e "  ${CYAN}${key})${NC} ${PLATFORMS[$key]} - ${PLATFORM_DESC[$key]}"
    done
    
    echo ""
    echo -e "  ${CYAN}a)${NC} 选择所有平台"
    echo -e "  ${CYAN}c)${NC} 自定义平台组合"
    echo -e "  ${CYAN}q)${NC} 退出"
    echo ""
}

# 选择单个平台
select_single_platform() {
    local choice
    read -p "请选择平台 (1-4, a, c, q): " choice
    
    case $choice in
        1|2|3|4)
            echo "${PLATFORMS[$choice]}"
            ;;
        a|A)
            echo "all"
            ;;
        c|C)
            select_custom_platforms
            ;;
        q|Q)
            print_info "退出"
            exit 0
            ;;
        *)
            print_error "无效选择"
            exit 1
            ;;
    esac
}

# 选择自定义平台组合
select_custom_platforms() {
    local selected_platforms=()
    local choice
    
    print_info "自定义平台选择 (输入平台编号，用空格分隔，按回车确认):"
    echo ""
    
    read -p "平台 (1-4): " choice
    
    # 解析用户输入
    for num in $choice; do
        if [[ -n "${PLATFORMS[$num]}" ]]; then
            selected_platforms+=("${PLATFORMS[$num]}")
        else
            print_warning "无效的平台编号: $num"
        fi
    done
    
    if [ ${#selected_platforms[@]} -eq 0 ]; then
        print_error "未选择任何平台"
        exit 1
    fi
    
    # 将平台列表转换为空格分隔的字符串
    local platform_string=$(IFS=' '; echo "${selected_platforms[*]}")
    echo "$platform_string"
}

# 更新配置文件
update_config() {
    local platforms=$1
    local config_file="$DOCKER_DIR/config/.env.multiarch"
    
    if [ ! -f "$config_file" ]; then
        print_error "配置文件不存在: $config_file"
        exit 1
    fi
    
    # 更新TARGET_PLATFORMS
    if [ "$platforms" = "all" ]; then
        platforms="linux/amd64 linux/arm64 linux/arm/v7"
    fi
    
    print_info "更新配置文件..."
    sed -i.bak "s/^TARGET_PLATFORMS=.*/TARGET_PLATFORMS=\"$platforms\"/" "$config_file"
    
    print_success "配置已更新"
    echo ""
    print_info "目标平台: $platforms"
}

# 显示后续操作建议
show_next_steps() {
    echo ""
    echo -e "${CYAN}========================================${NC}"
    echo -e "${CYAN}  后续操作${NC}"
    echo -e "${CYAN}========================================${NC}"
    echo ""
    echo "1. 构建多架构镜像:"
    echo "   make build-multiarch"
    echo "   或"
    echo "   ./docker/scripts/build/docker-build-multiarch.sh"
    echo ""
    echo "2. 构建特定架构镜像:"
    echo "   make build-amd64    # 构建AMD64镜像"
    echo "   make build-arm64    # 构建ARM64镜像"
    echo ""
    echo "3. 查看所有可用命令:"
    echo "   make help"
    echo ""
    echo -e "${CYAN}========================================${NC}"
}

# 主函数
main() {
    show_header
    show_system_info
    show_platforms
    
    local platforms=$(select_single_platform)
    
    if [ "$platforms" != "all" ]; then
        print_info "已选择平台: $platforms"
    else
        print_info "已选择所有平台"
    fi
    
    update_config "$platforms"
    show_next_steps
    
    print_success "平台选择完成！"
}

# 执行主函数
main "$@"

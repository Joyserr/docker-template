#!/bin/bash
# 多架构构建环境验证脚本

set -e

# 颜色输出
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
NC='\033[0m' # No Color

# 计数器
PASS=0
FAIL=0
WARN=0

# 打印信息函数
print_info() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

print_success() {
    echo -e "${GREEN}[✓ PASS]${NC} $1"
    ((PASS++))
}

print_warning() {
    echo -e "${YELLOW}[⚠ WARN]${NC} $1"
    ((WARN++))
}

print_error() {
    echo -e "${RED}[✗ FAIL]${NC} $1"
    ((FAIL++))
}

print_header() {
    echo ""
    echo -e "${CYAN}========================================${NC}"
    echo -e "${CYAN}  $1${NC}"
    echo -e "${CYAN}========================================${NC}"
    echo ""
}

# 检查Docker是否安装
check_docker() {
    print_header "检查Docker环境"
    
    if command -v docker &> /dev/null; then
        local version=$(docker --version)
        print_success "Docker已安装: $version"
        
        # 检查Docker版本
        local major_version=$(docker --version | grep -oP 'Docker version \K[0-9]+' || echo "0")
        if [ "$major_version" -ge 19 ]; then
            print_success "Docker版本满足要求 (>= 19.03)"
        else
            print_error "Docker版本过低，需要19.03或更高版本"
        fi
    else
        print_error "Docker未安装"
    fi
}

# 检查Docker Buildx
check_buildx() {
    print_header "检查Docker Buildx"
    
    if docker buildx version &> /dev/null; then
        local version=$(docker buildx version)
        print_success "Docker Buildx已安装: $version"
    else
        print_warning "Docker Buildx不可用，尝试启用实验性功能"
        export DOCKER_CLI_EXPERIMENTAL=enabled
        
        if docker buildx version &> /dev/null; then
            print_success "Docker Buildx已启用（实验性功能）"
        else
            print_error "Docker Buildx不可用，请升级Docker到19.03+版本"
        fi
    fi
}

# 检查QEMU模拟器
check_qemu() {
    print_header "检查QEMU模拟器"
    
    if docker run --rm --privileged tonistiigi/binfmt --install all &> /dev/null; then
        print_success "QEMU模拟器已安装"
    else
        print_warning "QEMU模拟器未安装或配置不完整"
        print_info "运行以下命令安装QEMU模拟器:"
        echo "  docker run --privileged --rm tonistiigi/binfmt --install all"
    fi
}

# 检查配置文件
check_config_files() {
    print_header "检查配置文件"
    
    local docker_dir="docker"
    local files=(
        "config/.env"
        "config/.env.multiarch"
        "Dockerfile"
        "docker-compose.yml"
        "MULTIARCH.md"
    )
    
    for file in "${files[@]}"; do
        if [ -f "$docker_dir/$file" ]; then
            print_success "配置文件存在: $docker_dir/$file"
        else
            print_error "配置文件缺失: $docker_dir/$file"
        fi
    done
}

# 检查脚本文件
check_scripts() {
    print_header "检查构建脚本"
    
    local scripts_dir="docker/scripts"
    local scripts=(
        "build/docker-build-multiarch.sh"
        "utils/select-platform.sh"
    )
    
    for script in "${scripts[@]}"; do
        if [ -f "$scripts_dir/$script" ]; then
            if [ -x "$scripts_dir/$script" ]; then
                print_success "脚本存在且可执行: $scripts_dir/$script"
            else
                print_warning "脚本存在但不可执行: $scripts_dir/$script"
                print_info "运行: chmod +x $scripts_dir/$script"
            fi
        else
            print_error "脚本缺失: $scripts_dir/$script"
        fi
    done
}

# 检查Makefile
check_makefile() {
    print_header "检查Makefile"
    
    if [ -f "Makefile" ]; then
        print_success "Makefile存在"
        
        # 检查多架构相关命令
        local commands=(
            "build-multiarch"
            "build-amd64"
            "build-arm64"
            "setup-buildx"
            "list-platforms"
        )
        
        for cmd in "${commands[@]}"; do
            if grep -q "^$cmd:" Makefile; then
                print_success "Makefile命令存在: $cmd"
            else
                print_error "Makefile命令缺失: $cmd"
            fi
        done
    else
        print_error "Makefile不存在"
    fi
}

# 检查Dockerfile
check_dockerfile() {
    print_header "检查Dockerfile"
    
    local dockerfile="docker/Dockerfile"
    
    if [ -f "$dockerfile" ]; then
        # 检查多架构支持参数
        local args=(
            "ARG TARGETPLATFORM"
            "ARG BUILDPLATFORM"
        )
        
        for arg in "${args[@]}"; do
            if grep -q "$arg" "$dockerfile"; then
                print_success "Dockerfile包含多架构参数: $arg"
            else
                print_warning "Dockerfile缺少多架构参数: $arg"
            fi
        done
    else
        print_error "Dockerfile不存在"
    fi
}

# 检查构建器
check_builder() {
    print_header "检查Docker Buildx构建器"
    
    if docker buildx inspect multiarch-builder &> /dev/null 2>&1; then
        print_success "多架构构建器已存在: multiarch-builder"
        
        # 显示构建器信息
        local builder_info=$(docker buildx inspect multiarch-builder --bootstrap 2>&1 || true)
        print_info "构建器信息:"
        echo "$builder_info" | head -10
    else
        print_warning "多架构构建器不存在"
        print_info "运行以下命令创建构建器:"
        echo "  make setup-buildx"
        echo "  或"
        echo "  docker buildx create --name multiarch-builder --driver docker-container --use"
    fi
}

# 显示系统信息
show_system_info() {
    print_header "系统信息"
    
    echo "操作系统: $(uname -s)"
    echo "内核版本: $(uname -r)"
    echo "架构: $(uname -m)"
    echo ""
    
    if command -v docker &> /dev/null; then
        echo "Docker版本: $(docker --version)"
        echo "Docker信息:"
        docker info 2>/dev/null | grep -E "Server Version|Operating System|Architecture" || true
    fi
}

# 显示支持的平台
show_supported_platforms() {
    print_header "支持的平台"
    
    echo "  - linux/amd64 (Intel/AMD 64位)"
    echo "  - linux/arm64 (ARM 64位)"
    echo "  - linux/arm/v7 (ARM 32位)"
    echo "  - linux/riscv64 (RISC-V 64位)"
    echo ""
    
    print_info "当前系统架构: $(uname -m)"
}

# 显示后续步骤
show_next_steps() {
    print_header "后续步骤"
    
    if [ $FAIL -eq 0 ]; then
        echo -e "${GREEN}所有检查通过！${NC}"
        echo ""
        echo "您可以开始构建多架构镜像："
        echo ""
        echo "1. 选择目标平台:"
        echo "   ./docker/scripts/utils/select-platform.sh"
        echo ""
        echo "2. 构建多架构镜像:"
        echo "   make build-multiarch"
        echo ""
        echo "3. 查看所有可用命令:"
        echo "   make help"
        echo ""
        echo "4. 查看详细文档:"
        echo "   cat docker/MULTIARCH.md"
    else
        echo -e "${RED}发现 $FAIL 个问题，请先解决后再继续${NC}"
        echo ""
        echo "常见解决方案:"
        echo ""
        echo "1. 升级Docker到19.03+版本"
        echo "2. 启用Docker Buildx实验性功能:"
        echo "   export DOCKER_CLI_EXPERIMENTAL=enabled"
        echo "3. 安装QEMU模拟器:"
        echo "   docker run --privileged --rm tonistiigi/binfmt --install all"
        echo "4. 创建多架构构建器:"
        echo "   make setup-buildx"
        echo ""
        echo "详细信息请参考: docker/MULTIARCH.md"
    fi
}

# 显示摘要
show_summary() {
    print_header "检查摘要"
    
    echo -e "通过: ${GREEN}$PASS${NC}"
    echo -e "警告: ${YELLOW}$WARN${NC}"
    echo -e "失败: ${RED}$FAIL${NC}"
    echo ""
    
    if [ $FAIL -eq 0 ]; then
        echo -e "${GREEN}✓ 环境配置正确，可以开始构建${NC}"
        return 0
    else
        echo -e "${RED}✗ 环境配置存在问题，请先解决${NC}"
        return 1
    fi
}

# 主函数
main() {
    clear
    echo -e "${CYAN}========================================${NC}"
    echo -e "${CYAN}  多架构构建环境验证${NC}"
    echo -e "${CYAN}========================================${NC}"
    
    show_system_info
    show_supported_platforms
    
    check_docker
    check_buildx
    check_qemu
    check_config_files
    check_scripts
    check_makefile
    check_dockerfile
    check_builder
    
    show_summary
    show_next_steps
    
    exit $([ $FAIL -eq 0 ] && echo 0 || echo 1)
}

# 执行主函数
main "$@"

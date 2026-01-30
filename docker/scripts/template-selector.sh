#!/bin/bash

# Docker Template Selector and Usage Script
# 用于选择和使用不同的Docker开发环境模板

# 颜色定义
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
PURPLE='\033[0;35m'
CYAN='\033[0;36m'
NC='\033[0m' # No Color

# 模板目录
TEMPLATES_DIR="docker/templates"

# 模板信息数组
ROS1_NOETIC="ROS1 Noetic (Ubuntu 20.04)"
ROS2_HUMBLE="ROS2 Humble (Ubuntu 22.04)"
ROS2_FOXY="ROS2 Foxy (Ubuntu 20.04)"
PYTHON_311="Python 3.11 开发环境"
PYTHON_312="Python 3.12 开发环境"
NODEJS_18="Node.js 18 开发环境"
NODEJS_20="Node.js 20 开发环境"
JAVA_11="Java 11 开发环境"
JAVA_17="Java 17 开发环境"
GO_22="Go 1.22 开发环境"
UBUNTU="Ubuntu 22.04 通用开发环境"

# 显示帮助信息
show_help() {
    echo -e "${CYAN}Docker 模板选择和使用工具${NC}"
    echo ""
    echo "用法: $0 [选项] [参数]"
    echo ""
    echo "选项:"
    echo "  -h, --help              显示此帮助信息"
    echo "  -l, --list             列出所有可用模板"
    echo "  -s, --select <模板>   选择并使用指定模板"
    echo "  -c, --copy <模板>     复制模板到主Dockerfile"
    echo "  -b, --build <模板>    选择模板并构建镜像"
    echo "  -r, --run <模板>      选择模板并运行容器"
    echo "  -i, --info <模板>     显示模板详细信息"
    echo ""
    echo "示例:"
    echo "  $0 -l                    # 列出所有模板"
    echo "  $0 -s ros1-noetic          # 选择ROS1 Noetic模板"
    echo "  $0 -s python-311          # 选择Python 3.11模板"
    echo "  $0 -c ros2-humble         # 复制ROS2模板"
    echo "  $0 -b nodejs-18            # 构建Node.js镜像"
    echo "  $0 -r java-17             # 运行Java容器"
}

# 列出所有可用模板
list_templates() {
    echo -e "${CYAN}可用的Docker开发环境模板：${NC}"
    echo ""
    echo -e "  ${GREEN}ros1-noetic${NC}      - ${YELLOW}$ROS1_NOETIC${NC}"
    echo -e "  ${GREEN}ros2-humble${NC}     - ${YELLOW}$ROS2_HUMBLE${NC}"
    echo -e "  ${GREEN}ros2-foxy${NC}       - ${YELLOW}$ROS2_FOXY${NC}"
    echo -e "  ${GREEN}python-3.11${NC}      - ${YELLOW}$PYTHON_311${NC}"
    echo -e "  ${GREEN}python-3.12${NC}      - ${YELLOW}$PYTHON_312${NC}"
    echo -e "  ${GREEN}nodejs-18${NC}        - ${YELLOW}$NODEJS_18${NC}"
    echo -e "  ${GREEN}nodejs-20${NC}        - ${YELLOW}$NODEJS_20${NC}"
    echo -e "  ${GREEN}java-11${NC}          - ${YELLOW}$JAVA_11${NC}"
    echo -e "  ${GREEN}java-17${NC}          - ${YELLOW}$JAVA_17${NC}"
    echo -e "  ${GREEN}go-22${NC}            - ${YELLOW}$GO_22${NC}"
    echo -e "  ${GREEN}ubuntu${NC}           - ${YELLOW}$UBUNTU${NC}"
    echo ""
    echo -e "${BLUE}使用方法：${NC}"
    echo "  $0 -s <模板名>     # 选择模板"
    echo "  $0 -c <模板名>     # 复制模板"
    echo "  $0 -b <模板名>     # 构建镜像"
    echo "  $0 -r <模板名>     # 运行容器"
}

# 显示模板详细信息
show_template_info() {
    local template=$1
    
    if [[ -z "$template" ]]; then
        echo -e "${RED}错误：请指定模板名称${NC}"
        echo "使用 '$0 -l' 查看可用模板"
        return 1
    fi
    
    echo -e "${CYAN}模板信息：${NC}"
    case $template in
        "ros1-noetic")
            echo "  名称：${GREEN}ros1-noetic${NC}"
            echo "  描述：${YELLOW}$ROS1_NOETIC${NC}"
            check_template_file "$TEMPLATES_DIR/ros1/Dockerfile"
            ;;
        "ros2-humble")
            echo "  名称：${GREEN}ros2-humble${NC}"
            echo "  描述：${YELLOW}$ROS2_HUMBLE${NC}"
            check_template_file "$TEMPLATES_DIR/ros2/Dockerfile.humble"
            ;;
        "ros2-foxy")
            echo "  名称：${GREEN}ros2-foxy${NC}"
            echo "  描述：${YELLOW}$ROS2_FOXY${NC}"
            check_template_file "$TEMPLATES_DIR/ros2/Dockerfile.foxy"
            ;;
        "python-3.11")
            echo "  名称：${GREEN}python-3.11${NC}"
            echo "  描述：${YELLOW}$PYTHON_311${NC}"
            check_template_file "$TEMPLATES_DIR/python/Dockerfile.3.11"
            ;;
        "python-3.12")
            echo "  名称：${GREEN}python-3.12${NC}"
            echo "  描述：${YELLOW}$PYTHON_312${NC}"
            check_template_file "$TEMPLATES_DIR/python/Dockerfile.3.12"
            ;;
        "nodejs-18")
            echo "  名称：${GREEN}nodejs-18${NC}"
            echo "  描述：${YELLOW}$NODEJS_18${NC}"
            check_template_file "$TEMPLATES_DIR/nodejs/Dockerfile.18"
            ;;
        "nodejs-20")
            echo "  名称：${GREEN}nodejs-20${NC}"
            echo "  描述：${YELLOW}$NODEJS_20${NC}"
            check_template_file "$TEMPLATES_DIR/nodejs/Dockerfile.20"
            ;;
        "java-11")
            echo "  名称：${GREEN}java-11${NC}"
            echo "  描述：${YELLOW}$JAVA_11${NC}"
            check_template_file "$TEMPLATES_DIR/java/Dockerfile.11"
            ;;
        "java-17")
            echo "  名称：${GREEN}java-17${NC}"
            echo "  描述：${YELLOW}$JAVA_17${NC}"
            check_template_file "$TEMPLATES_DIR/java/Dockerfile.17"
            ;;
        "go-22")
            echo "  名称：${GREEN}go-22${NC}"
            echo "  描述：${YELLOW}$GO_22${NC}"
            check_template_file "$TEMPLATES_DIR/go/Dockerfile.22"
            ;;
        "ubuntu")
            echo "  名称：${GREEN}ubuntu${NC}"
            echo "  描述：${YELLOW}$UBUNTU${NC}"
            check_template_file "$TEMPLATES_DIR/ubuntu/Dockerfile"
            ;;
        *)
            echo -e "${RED}错误：未知的模板 '$template'${NC}"
            echo "使用 '$0 -l' 查看可用模板"
            return 1
            ;;
    esac
}

# 检查模板文件
check_template_file() {
    local file_path=$1
    if [[ -f "$file_path" ]]; then
        echo "  文件：${GREEN}$file_path${NC}"
        echo "  状态：${GREEN}存在${NC}"
    else
        echo "  文件：${RED}$file_path${NC}"
        echo "  状态：${RED}不存在${NC}"
    fi
}

# 选择模板交互式
select_template() {
    echo -e "${CYAN}请选择Docker开发环境模板：${NC}"
    echo ""
    echo -e "  ${GREEN}1${NC}. ${YELLOW}ros1-noetic${NC}     - ${BLUE}$ROS1_NOETIC${NC}"
    echo -e "  ${GREEN}2${NC}. ${YELLOW}ros2-humble${NC}     - ${BLUE}$ROS2_HUMBLE${NC}"
    echo -e "  ${GREEN}3${NC}. ${YELLOW}ros2-foxy${NC}       - ${BLUE}$ROS2_FOXY${NC}"
    echo -e "  ${GREEN}4${NC}. ${YELLOW}python-3.11${NC}      - ${BLUE}$PYTHON_311${NC}"
    echo -e "  ${GREEN}5${NC}. ${YELLOW}python-3.12${NC}      - ${BLUE}$PYTHON_312${NC}"
    echo -e "  ${GREEN}6${NC}. ${YELLOW}nodejs-18${NC}        - ${BLUE}$NODEJS_18${NC}"
    echo -e "  ${GREEN}7${NC}. ${YELLOW}nodejs-20${NC}        - ${BLUE}$NODEJS_20${NC}"
    echo -e "  ${GREEN}8${NC}. ${YELLOW}java-11${NC}          - ${BLUE}$JAVA_11${NC}"
    echo -e "  ${GREEN}9${NC}. ${YELLOW}java-17${NC}          - ${BLUE}$JAVA_17${NC}"
    echo -e "  ${GREEN}10${NC}. ${YELLOW}go-22${NC}            - ${BLUE}$GO_22${NC}"
    echo -e "  ${GREEN}11${NC}. ${YELLOW}ubuntu${NC}           - ${BLUE}$UBUNTU${NC}"
    
    echo ""
    read -p "请输入模板编号 (1-11) [输入q退出]: " choice
    
    case $choice in
        1)
            copy_template "ros1-noetic"
            ;;
        2)
            copy_template "ros2-humble"
            ;;
        3)
            copy_template "ros2-foxy"
            ;;
        4)
            copy_template "python-3.11"
            ;;
        5)
            copy_template "python-3.12"
            ;;
        6)
            copy_template "nodejs-18"
            ;;
        7)
            copy_template "nodejs-20"
            ;;
        8)
            copy_template "java-11"
            ;;
        9)
            copy_template "java-17"
            ;;
        10)
            copy_template "go-22"
            ;;
        11)
            copy_template "ubuntu"
            ;;
        q|Q)
            echo "退出模板选择"
            return 0
            ;;
        *)
            echo -e "${RED}无效的选择：$choice${NC}"
            return 1
            ;;
    esac
}

# 复制模板
copy_template() {
    local template=$1
    
    if [[ -z "$template" ]]; then
        echo -e "${RED}错误：请指定模板名称${NC}"
        return 1
    fi
    
    local source_file=""
    local bashrc_file=""
    local requirements_file=""
    local package_file=""
    local pom_file=""
    
    # 确定源文件和配置文件
    case $template in
        "ros1-noetic")
            source_file="$TEMPLATES_DIR/ros1/Dockerfile"
            bashrc_file="$TEMPLATES_DIR/ros1/bashrc"
            requirements_file="$TEMPLATES_DIR/ros1/requirements.txt"
            ;;
        "ros2-humble")
            source_file="$TEMPLATES_DIR/ros2/Dockerfile.humble"
            bashrc_file="$TEMPLATES_DIR/ros2/bashrc"
            requirements_file="$TEMPLATES_DIR/ros2/requirements.txt"
            ;;
        "ros2-foxy")
            source_file="$TEMPLATES_DIR/ros2/Dockerfile.foxy"
            bashrc_file="$TEMPLATES_DIR/ros2/bashrc"
            requirements_file="$TEMPLATES_DIR/ros2/requirements.txt"
            ;;
        "python-3.11")
            source_file="$TEMPLATES_DIR/python/Dockerfile.3.11"
            bashrc_file="$TEMPLATES_DIR/python/bashrc"
            requirements_file="$TEMPLATES_DIR/python/requirements.txt"
            ;;
        "python-3.12")
            source_file="$TEMPLATES_DIR/python/Dockerfile.3.12"
            bashrc_file="$TEMPLATES_DIR/python/bashrc"
            requirements_file="$TEMPLATES_DIR/python/requirements.txt"
            ;;
        "nodejs-18")
            source_file="$TEMPLATES_DIR/nodejs/Dockerfile.18"
            bashrc_file="$TEMPLATES_DIR/nodejs/bashrc"
            package_file="$TEMPLATES_DIR/nodejs/package.json"
            ;;
        "nodejs-20")
            source_file="$TEMPLATES_DIR/nodejs/Dockerfile.20"
            bashrc_file="$TEMPLATES_DIR/nodejs/bashrc"
            package_file="$TEMPLATES_DIR/nodejs/package.json"
            ;;
        "java-11")
            source_file="$TEMPLATES_DIR/java/Dockerfile.11"
            bashrc_file="$TEMPLATES_DIR/java/bashrc"
            pom_file="$TEMPLATES_DIR/java/pom.xml"
            ;;
        "java-17")
            source_file="$TEMPLATES_DIR/java/Dockerfile.17"
            bashrc_file="$TEMPLATES_DIR/java/bashrc"
            pom_file="$TEMPLATES_DIR/java/pom.xml"
            ;;
        "go-22")
            source_file="$TEMPLATES_DIR/go/Dockerfile.22"
            bashrc_file="$TEMPLATES_DIR/go/bashrc"
            ;;
        "ubuntu")
            source_file="$TEMPLATES_DIR/ubuntu/Dockerfile"
            bashrc_file="$TEMPLATES_DIR/ubuntu/bashrc"
            ;;
        *)
            echo -e "${RED}错误：未知的模板 '$template'${NC}"
            return 1
            ;;
    esac
    
    # 检查源文件是否存在
    if [[ ! -f "$source_file" ]]; then
        echo -e "${RED}错误：模板文件不存在：$source_file${NC}"
        return 1
    fi
    
    # 备份现有的Dockerfile
    if [[ -f "docker/Dockerfile" ]]; then
        cp docker/Dockerfile docker/Dockerfile.backup.$(date +%Y%m%d_%H%M%S)
        echo -e "${YELLOW}已备份现有Dockerfile${NC}"
    fi
    
    # 复制模板文件
    cp "$source_file" docker/Dockerfile
    
    # 复制相应的配置文件
    if [[ -n "$bashrc_file" && -f "$bashrc_file" ]]; then
        cp "$bashrc_file" docker/config/bashrc
        echo -e "${GREEN}已更新bashrc配置${NC}"
    fi
    
    if [[ -n "$requirements_file" && -f "$requirements_file" ]]; then
        cp "$requirements_file" docker/requirements.txt
        echo -e "${GREEN}已更新requirements.txt${NC}"
    fi
    
    if [[ -n "$package_file" && -f "$package_file" ]]; then
        cp "$package_file" package.json
        echo -e "${GREEN}已创建package.json${NC}"
    fi
    
    if [[ -n "$pom_file" && -f "$pom_file" ]]; then
        cp "$pom_file" pom.xml
        echo -e "${GREEN}已创建pom.xml${NC}"
    fi
    
    echo -e "${GREEN}✓ 模板 '$template' 已成功复制到 docker/Dockerfile${NC}"
    echo -e "${BLUE}下一步：${NC}"
    echo "  1. 运行 'make build' 构建镜像"
    echo "  2. 运行 'make run' 启动容器"
}

# 构建镜像
build_template() {
    local template=$1
    copy_template "$template"
    if [[ $? -eq 0 ]]; then
        echo -e "${CYAN}开始构建镜像...${NC}"
        make build
    fi
}

# 运行容器
run_template() {
    local template=$1
    build_template "$template"
    if [[ $? -eq 0 ]]; then
        echo -e "${CYAN}启动容器...${NC}"
        make run
    fi
}

# 主函数
main() {
    # 检查模板目录是否存在
    if [[ ! -d "$TEMPLATES_DIR" ]]; then
        echo -e "${RED}错误：模板目录不存在：$TEMPLATES_DIR${NC}"
        echo "请先运行模板创建脚本"
        return 1
    fi
    
    case "${1:-}" in
        -h|--help)
            show_help
            ;;
        -l|--list)
            list_templates
            ;;
        -i|--info)
            show_template_info "$2"
            ;;
        -s|--select)
            select_template
            ;;
        -c|--copy)
            copy_template "$2"
            ;;
        -b|--build)
            build_template "$2"
            ;;
        -r|--run)
            run_template "$2"
            ;;
        *)
            # 没有参数时显示交互式选择
            select_template
            ;;
    esac
}

# 运行主函数
main "$@"
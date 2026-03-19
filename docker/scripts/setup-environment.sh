#!/bin/bash
# ========================================
# 环境一键配置向导 - 新手友好版
# ========================================

set -e

# 加载公共函数
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/utils/common.sh"

# 获取项目路径
PROJECT_ROOT=$(get_project_root)
cd "$PROJECT_ROOT"

# 颜色定义
STEP_COLOR='\033[1;36m'    # 青色 - 步骤标题
ACTION_COLOR='\033[1;33m'   # 黄色 - 操作提示
SUCCESS_COLOR='\033[1;32m'  # 绿色 - 成功信息
INFO_COLOR='\033[0;34m'     # 蓝色 - 补充信息
NC='\033[0m'

print_step() {
    echo -e "\n${STEP_COLOR}▶ $1${NC}"
    echo "----------------------------------------"
}

print_action() {
    echo -e "${ACTION_COLOR}💡 $1${NC}"
}

print_success() {
    echo -e "${SUCCESS_COLOR}✓ $1${NC}"
}

print_info() {
    echo -e "${INFO_COLOR}ⓘ $1${NC}"
}

# 检查前置条件
check_prerequisites() {
    print_step "检查系统环境"
    
    # 检查Docker
    if ! command -v docker &> /dev/null; then
        echo -e "${RED}✗ 未检测到 Docker，请先安装 Docker${NC}"
        echo "  macOS: brew install docker 或下载 Docker Desktop"
        echo "  Ubuntu: curl -fsSL https://get.docker.com | sh"
        exit 1
    fi
    
    # 检查Docker服务
    if ! docker info &> /dev/null; then
        echo -e "${RED}✗ Docker 服务未运行，请启动 Docker${NC}"
        exit 1
    fi
    
    print_success "Docker 环境正常"
    
    # 检查Make
    if ! command -v make &> /dev/null; then
        echo -e "${YELLOW}⚠ 未检测到 make 命令${NC}"
        echo "  建议安装 make 以获得更好的使用体验"
    else
        print_success "Make 工具可用"
    fi
}

# 选择开发环境类型
select_environment_type() {
    print_step "选择开发环境类型"
    
    echo -e "${INFO_COLOR}请选择您的主要开发需求：${NC}"
    echo ""
    echo -e "  ${ACTION_COLOR}1. ROS 机器人开发${NC}"
    echo -e "     • ROS1 Noetic (经典稳定版)"
    echo -e "     • ROS2 Humble/Foxy/Jazzy (新一代)"
    echo ""
    echo -e "  ${ACTION_COLOR}2. 通用编程语言${NC}"
    echo -e "     • Python (数据科学/AI)"
    echo -e "     • Node.js (Web/前端)"
    echo -e "     • Java (企业级应用)"
    echo -e "     • Go (云原生/后端)"
    echo ""
    echo -e "  ${ACTION_COLOR}3. 系统环境${NC}"
    echo -e "     • Ubuntu (纯净Linux环境)"
    echo ""
    
    while true; do
        read -p "请输入选择 (1-3): " choice
        
        case $choice in
            1)
                select_ros_version
                break
                ;;
            2)
                select_programming_language
                break
                ;;
            3)
                setup_ubuntu_environment
                break
                ;;
            *)
                echo -e "${RED}无效选择，请输入 1-3${NC}"
                ;;
        esac
    done
}

# 选择ROS版本
select_ros_version() {
    print_step "选择ROS版本"
    
    echo -e "${INFO_COLOR}ROS版本对比：${NC}"
    echo "  ROS1 Noetic: 稳定成熟，社区资源丰富，适合传统机器人项目"
    echo "  ROS2 Humble: 新一代架构，性能更好，长期支持 (Ubuntu 22.04)"
    echo "  ROS2 Jazzy: 最新LTS版本，基于Ubuntu 24.04，功能最全"
    echo ""
    
    echo -e "${ACTION_COLOR}推荐选择：${NC}"
    echo "  • 初学者/传统项目 → ROS1 Noetic"
    echo "  • 新项目/现代机器人 → ROS2 Humble"
    echo "  • 追求最新特性 → ROS2 Jazzy"
    echo ""
    
    PS3="请选择ROS版本: "
    select ros_choice in "ROS1 Noetic" "ROS2 Humble" "ROS2 Foxy" "ROS2 Jazzy"; do
        case $ros_choice in
            "ROS1 Noetic")
                setup_ros_environment "ros1-noetic"
                break
                ;;
            "ROS2 Humble")
                setup_ros_environment "ros2-humble"
                break
                ;;
            "ROS2 Foxy")
                setup_ros_environment "ros2-foxy"
                break
                ;;
            "ROS2 Jazzy")
                setup_ros_environment "ros2-jazzy"
                break
                ;;
            *)
                echo -e "${RED}无效选择${NC}"
                ;;
        esac
    done
}

# 选择编程语言
select_programming_language() {
    print_step "选择编程语言"
    
    PS3="请选择编程语言: "
    select lang_choice in "Python 3.11" "Python 3.12" "Node.js 18" "Node.js 20" "Java 11" "Java 17" "Go 1.22"; do
        case $lang_choice in
            "Python 3.11")
                setup_language_environment "python-3.11"
                break
                ;;
            "Python 3.12")
                setup_language_environment "python-3.12"
                break
                ;;
            "Node.js 18")
                setup_language_environment "nodejs-18"
                break
                ;;
            "Node.js 20")
                setup_language_environment "nodejs-20"
                break
                ;;
            "Java 11")
                setup_language_environment "java-11"
                break
                ;;
            "Java 17")
                setup_language_environment "java-17"
                break
                ;;
            "Go 1.22")
                setup_language_environment "go-22"
                break
                ;;
            *)
                echo -e "${RED}无效选择${NC}"
                ;;
        esac
    done
}

# 设置ROS环境
setup_ros_environment() {
    local template=$1
    print_step "配置 $template 环境"
    
    # 自动初始化配置
    print_action "初始化环境配置..."
    make init > /dev/null 2>&1 || true
    
    # 应用模板
    print_action "应用开发环境模板..."
    make template-use TEMPLATE="$template"
    
    print_success "ROS环境配置完成！"
    show_next_steps "ROS"
}

# 设置语言环境
setup_language_environment() {
    local template=$1
    print_step "配置 $template 环境"
    
    # 自动初始化配置
    print_action "初始化环境配置..."
    make init > /dev/null 2>&1 || true
    
    # 应用模板
    print_action "应用开发环境模板..."
    make template-use TEMPLATE="$template"
    
    print_success "编程环境配置完成！"
    show_next_steps "Language"
}

# 设置Ubuntu环境
setup_ubuntu_environment() {
    print_step "配置 Ubuntu 环境"
    
    # 自动初始化配置
    print_action "初始化环境配置..."
    make init > /dev/null 2>&1 || true
    
    # 应用模板
    print_action "应用Ubuntu模板..."
    make template-use TEMPLATE="ubuntu"
    
    print_success "Ubuntu环境配置完成！"
    show_next_steps "Ubuntu"
}

# 显示后续步骤
show_next_steps() {
    local env_type=$1
    
    print_step "环境已准备就绪！"
    
    echo -e "${SUCCESS_COLOR}恭喜！您的开发环境已配置完成。${NC}"
    echo ""
    
    echo -e "${INFO_COLOR}接下来您可以：${NC}"
    echo ""
    echo -e "${ACTION_COLOR}1. 构建Docker镜像${NC}"
    echo "   $ make build"
    echo ""
    echo -e "${ACTION_COLOR}2. 启动开发容器${NC}"
    echo "   $ make run"
    echo ""
    echo -e "${ACTION_COLOR}3. 查看常用命令${NC}"
    echo "   $ make help"
    echo ""
    
    if [[ "$env_type" == "ROS" ]]; then
        echo -e "${INFO_COLOR}ROS开发提示：${NC}"
        echo "  • 容器启动后可直接使用 colcon build 编译工作空间"
        echo "  • 支持RViz、Gazebo等图形界面工具"
        echo "  • 工作空间位于 ~/workspace/src"
        echo ""
    fi
    
    echo -e "${INFO_COLOR}快捷操作：${NC}"
    echo "  构建并运行：make template-run TEMPLATE=$template_name"
    echo "  重新构建：make rebuild"
    echo "  停止容器：make stop"
    echo ""
    
    # 询问是否立即构建
    read -p "是否现在开始构建镜像？(Y/n): " -n 1 -r
    echo
    if [[ ! $REPLY =~ ^[Nn]$ ]]; then
        print_action "开始构建镜像..."
        make build
        print_success "构建完成！"
        
        read -p "是否立即启动容器？(Y/n): " -n 1 -r
        echo
        if [[ ! $REPLY =~ ^[Nn]$ ]]; then
            print_action "启动开发容器..."
            make run
        fi
    fi
}

# 主程序入口
main() {
    echo -e "${STEP_COLOR}"
    echo "=========================================="
    echo "    Docker 开发环境一键配置向导"
    echo "==========================================${NC}"
    echo ""
    
    # 检查环境
    check_prerequisites
    
    # 选择环境类型
    select_environment_type
    
    echo ""
    echo -e "${SUCCESS_COLOR}🎉 环境配置向导完成！${NC}"
    echo -e "${INFO_COLOR}如有任何问题，请运行 'make help' 查看帮助${NC}"
}

# 执行主程序
main "$@"
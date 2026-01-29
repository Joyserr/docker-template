# ROS Docker 开发环境

基于 Docker 的 ROS 开发环境，简单、直接、易用。

## 🚀 快速开始

### 1. 初始化配置

```bash
make init
```

自动检测并配置用户信息和工作空间路径。

### 2. 构建镜像

```bash
make build
```

### 3. 运行容器

```bash
# 交互式运行（退出后容器自动删除）
make run

# 或后台运行
make run-d
make exec  # 进入容器
```

## 📋 可用命令

```bash
make help      # 显示帮助信息
make init      # 初始化环境配置
make build     # 构建 Docker 镜像
make run       # 交互式运行容器
make run-d     # 后台运行容器
make exec      # 进入运行中的容器
make stop      # 停止容器
make clean     # 清理容器和镜像
make rebuild   # 重新构建镜像
make logs      # 查看容器日志
make status    # 查看容器和镜像状态
```

## ⚙️ 配置文件

编辑 `docker/.env` 文件自定义配置：

```bash
# 用户信息（自动生成）
USER_NAME=your_name
USER_UID=1000
USER_GID=1000

# 镜像配置
IMAGE_NAME=ros-dev
IMAGE_TAG=latest
CONTAINER_NAME=ros_dev_container

# ROS 版本
ROS_DISTRO=noetic

# 工作空间路径（自动生成）
WORKSPACE_DIR=/path/to/your/workspace
```

## 📁 目录结构

```
.
├── docker/
│   ├── config/
│   │   └── bashrc              # 容器内 bash 配置
│   ├── Dockerfile              # 镜像定义
│   ├── docker-compose.yml      # Compose 配置（可选）
│   ├── requirements.txt        # Python 依赖
│   └── .env                    # 环境变量配置
├── Makefile                    # 主要命令入口
└── src/                        # ROS 工作空间源码
```

## ✨ 特性

- **简单直接**: 一个 Makefile 搞定所有操作
- **自动配置**: 自动检测用户信息，避免权限问题
- **GUI 支持**: 支持 RViz、rqt 等图形界面工具
- **实时同步**: 工作空间挂载，代码实时同步

## 📝 说明

- 容器使用 host 网络模式，方便 ROS 节点通信
- 容器内用户与主机用户 UID/GID 一致，避免文件权限问题
- 支持 X11 转发，可在容器内运行 GUI 程序

# ROS Noetic Docker 开发环境

这是一个基于 Docker 的 ROS Noetic 开发环境配置，支持完整的容器化开发工作流程。

## 📋 目录结构

```
kudan_ws/
├── docker/                     # Docker相关配置目录
│   ├── config/                  # 容器配置文件目录
│   │   └── bashrc              # 容器专用 bashrc 配置
│   ├── scripts/                # Shell脚本目录
│   │   ├── init-env.sh         # 初始化环境脚本
│   │   ├── docker-build.sh     # 构建镜像脚本
│   │   ├── docker-run.sh       # 运行容器脚本（交互式）
│   │   ├── docker-run-detach.sh # 后台运行容器脚本
│   │   ├── docker-exec.sh      # 进入容器脚本
│   │   └── docker-stop.sh      # 停止容器脚本
│   ├── Dockerfile              # Docker镜像构建文件
│   ├── docker-compose.yml      # Docker Compose配置
│   ├── requirements.txt        # Python依赖包列表
│   └── .env                    # 环境变量配置文件
├── Makefile                    # Make命令集合（推荐使用）
├── README.md                   # 本文档
└── src/                        # ROS工作空间源码目录
```

## ✨ 特性

- ✅ **自动化配置**: 自动检测用户信息和工作空间路径
- ✅ **Python 依赖管理**: 支持 requirements.txt 自动安装
- ✅ **丰富的快捷命令**: 容器内预设丰富的 bash 别名和函数
- ✅ **权限一致性**: 容器内用户 UID/GID 与主机一致，避免文件权限问题
- ✅ **GUI 支持**: 支持 RViz、rqt 等 GUI 工具（通过 X11 转发）
- ✅ **工作空间挂载**: 主机工作空间实时同步到容器
- ✅ **网络互通**: 使用 host 网络模式，简化 ROS 节点通信
- ✅ **多种使用方式**: 支持 Makefile、Shell 脚本、Docker Compose

## 🚀 快速开始

### 前置要求

- Docker 已安装（版本 >= 19.03）
- Docker Compose 已安装（可选）
- Make 工具（可选，推荐）

### 1. 初始化环境配置（推荐）

自动检测并配置环境变量：

```bash
# 使用 Makefile（推荐）
make init

# 或直接运行脚本
./docker/scripts/init-env.sh
```

该命令会自动：
- 检测当前用户名、UID、GID
- 检测工作空间路径
- 生成 `docker/.env` 配置文件
- 备份现有配置（如果存在）

**手动配置（可选）**

如果不使用自动初始化，也可以手动查看并修改 `docker/.env` 文件：

```bash
# 用户配置（自动生成）
USER_NAME=duboping
USER_UID=1000
USER_GID=1000

# Docker镜像配置
IMAGE_NAME=ros-kudan-dev
IMAGE_TAG=latest
CONTAINER_NAME=kudan_ws_container

# ROS版本配置
ROS_DISTRO=noetic

# 工作空间路径（自动生成）
WORKSPACE_DIR=/home/duboping/public/kudan/kudan_ws
```

### 2. 配置 Python 依赖（可选）

如果需要安装额外的 Python 包，编辑 `docker/requirements.txt` 文件：

```bash
# 取消注释并添加需要的包
numpy>=1.19.0
matplotlib>=3.3.0
opencv-python>=4.5.0
# ... 添加更多包
```

镜像构建时会自动安装这些依赖。

### 3. 构建 Docker 镜像

**方式一：使用 Makefile（推荐）**

```bash
make build
```

**方式二：使用 Shell 脚本**

```bash
./docker/scripts/docker-build.sh
```

**方式三：使用 Docker Compose**

```bash
cd docker
docker-compose build
```

### 4. 运行容器

**方式一：交互式运行（退出后自动删除容器）**

```bash
# 使用 Makefile
make run

# 使用 Shell 脚本
./docker/scripts/docker-run.sh
```

**方式二：后台运行**

```bash
# 使用 Makefile
make run-detach

# 使用 Shell 脚本
./docker/scripts/docker-run-detach.sh

# 使用 Docker Compose
cd docker
docker-compose up -d
```

### 5. 进入容器

如果容器在后台运行，可以使用以下命令进入：

```bash
# 使用 Makefile
make exec

# 使用 Shell 脚本
./docker/scripts/docker-exec.sh

# 使用 Docker Compose
cd docker
docker-compose exec ros-dev bash
```

## 📖 详细使用说明

### Makefile 命令

查看所有可用命令：

```bash
make help
```

常用命令：

| 命令 | 说明 |
|------|------|
| `make help` | 显示帮助信息 |
| `make init` | 初始化环境配置（自动检测系统信息） |
| `make build` | 构建 Docker 镜像 |
| `make run` | 运行容器（交互式） |
| `make run-detach` | 后台运行容器 |
| `make exec` | 进入运行中的容器 |
| `make stop` | 停止并删除容器 |
| `make clean` | 清理容器和镜像 |
| `make rebuild` | 清理并重新构建镜像 |
| `make logs` | 查看容器日志 |
| `make status` | 查看容器状态 |

### Shell 脚本使用

所有脚本都位于 `docker/scripts/` 目录下，已添加可执行权限：

```bash
# 构建镜像
./docker/scripts/docker-build.sh

# 运行容器（交互式）
./docker/scripts/docker-run.sh

# 后台运行容器
./docker/scripts/docker-run-detach.sh

# 进入容器
./docker/scripts/docker-exec.sh

# 停止容器
./docker/scripts/docker-stop.sh
```

### Docker Compose 使用

```bash
# 进入 docker 目录
cd docker

# 构建并启动
docker-compose up -d

# 进入容器
docker-compose exec ros-dev bash

# 查看日志
docker-compose logs -f

# 停止
docker-compose down

# 重新构建
docker-compose build --no-cache
```

## 🔧 容器内开发

### ROS 环境

容器内已自动配置 ROS 环境，启动后即可使用：

```bash
# 检查 ROS 环境
echo $ROS_DISTRO  # 应输出: noetic

# 查看 ROS 版本
rosversion -d

# 构建工作空间
cd ~/catkin_ws
catkin_make

# 或使用 catkin build（推荐）
catkin build
```

### 预设别名和快捷命令

容器内已配置丰富的 bash 别名和快捷命令：

**工作空间导航：**
```bash
cw    # cd ~/catkin_ws
cs    # cd ~/catkin_ws/src
```

**构建命令：**
```bash
cm       # catkin_make
cb       # catkin build
remake   # 清理并重新构建
soc      # 重新加载环境
```

**ROS 命令别名：**
```bash
rt       # rostopic
rn       # rosnode
rp       # rosparam
rs       # rosservice
rl       # roslaunch
rr       # rosrun
```

**实用函数：**
```bash
create_ros_pkg <name> [deps]  # 快速创建 ROS 包
find_pkg <name>               # 查找包路径
topic_echo <topic>            # 快速监听话题
```

### 安装额外依赖

**安装 ROS 包：**
```bash
sudo apt-get update
sudo apt-get install ros-noetic-<package-name>
```

**使用 rosdep 安装依赖：**
```bash
cd ~/catkin_ws
rosdep install --from-paths src --ignore-src -r -y
```

**安装 Python 包：**
```bash
# 在容器内
pip3 install --user <package-name>

# 或在构建镜像前编辑 docker/requirements.txt
```

## 🖥️ GUI 应用支持

### RViz 示例

```bash
# 在容器内运行
roscore &
rviz
```

### rqt 工具

```bash
# 在容器内运行
rqt
```

如果遇到 GUI 显示问题，在主机上执行：

```bash
xhost +local:docker
```

## 📝 常见问题

### 1. 权限问题

**问题**: 容器内创建的文件在主机上无法访问

**解决**: 确保 `.env` 文件中的 `USER_UID` 和 `USER_GID` 与主机用户一致。可以通过以下命令查看：

```bash
id -u  # 查看 UID
id -g  # 查看 GID
```

### 2. GUI 无法显示

**问题**: RViz 或 rqt 无法启动

**解决**: 在主机上允许 Docker 访问 X11：

```bash
xhost +local:docker
```

如果使用 SSH 连接，需要启用 X11 转发：

```bash
ssh -X user@host
```

### 3. 网络连接问题

**问题**: ROS 节点之间无法通信

**解决**: 确保容器使用 `--network host` 模式（配置文件中已设置）

### 4. 容器名称冲突

**问题**: 提示容器名称已存在

**解决**: 先停止并删除旧容器：

```bash
make stop
# 或
docker stop kudan_ws_container && docker rm kudan_ws_container
```

## 🔄 工作流程示例

### 典型开发流程

```bash
# 1. 构建镜像（首次或 Dockerfile 修改后）
make build

# 2. 后台启动容器
make run-detach

# 3. 进入容器
make exec

# 4. 在容器内开发
cd ~/catkin_ws/src
# ... 编写代码 ...
cd ~/catkin_ws
catkin_make
source devel/setup.bash
rosrun <package> <node>

# 5. 退出容器（容器继续运行）
exit

# 6. 需要时再次进入
make exec

# 7. 完成工作后停止容器
make stop
```

### 多终端工作

```bash
# 终端1: 启动 roscore
make run-detach
make exec
roscore

# 终端2: 运行节点
make exec
rosrun <package> <node>

# 终端3: 查看话题
make exec
rostopic list
```

## 📦 自定义配置

### 修改 ROS 版本

编辑 `.env` 文件：

```bash
ROS_DISTRO=melodic  # 或 foxy, humble 等
```

然后重新构建：

```bash
make rebuild
```

### 添加额外的软件包

编辑 `Dockerfile`，在 `RUN apt-get install` 部分添加所需包：

```dockerfile
RUN apt-get update && apt-get install -y \
    # ... 现有包 ...
    ros-${ROS_DISTRO}-your-package \
    && rm -rf /var/lib/apt/lists/*
```

### 挂载额外目录

编辑 `Makefile` 或 `docker-compose.yml`，添加 volume 挂载：

```yaml
volumes:
  - ${WORKSPACE_DIR}:/home/${USER_NAME}/catkin_ws
  - /path/on/host:/path/in/container  # 添加新的挂载
```

## 🛡️ 注意事项

1. **数据持久化**: 容器内 `~/catkin_ws` 目录已挂载到主机，数据会自动保存
2. **容器删除**: 使用 `--rm` 标志的容器退出后会自动删除，但挂载的数据不会丢失
3. **特权模式**: 容器使用 `--privileged` 模式以支持某些硬件访问，注意安全性
4. **网络模式**: 使用 host 网络模式，容器与主机共享网络栈

## 📚 参考资源

- [ROS Noetic 官方文档](http://wiki.ros.org/noetic)
- [Docker 官方文档](https://docs.docker.com/)
- [ROS Docker 最佳实践](http://wiki.ros.org/docker/Tutorials)

## 📄 许可证

本项目配置文件遵循 MIT 许可证。

## 🤝 贡献

欢迎提交 Issue 和 Pull Request！

---

**Happy Coding! 🚀**

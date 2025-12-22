# ROS Noetic Docker 开发环境

这是一个基于 Docker 的 ROS Noetic 开发环境配置，支持完整的容器化开发工作流程。

## 📋 目录结构

```
kudan_ws/
├── docker/                     # Docker相关配置目录
│   ├── Dockerfile              # Docker镜像构建文件
│   ├── docker-compose.yml      # Docker Compose配置
│   ├── .env                    # 环境变量配置文件
│   └── scripts/                # Shell脚本目录
│       ├── docker-build.sh     # 构建镜像脚本
│       ├── docker-run.sh       # 运行容器脚本（交互式）
│       ├── docker-run-detach.sh # 后台运行容器脚本
│       ├── docker-exec.sh      # 进入容器脚本
│       └── docker-stop.sh      # 停止容器脚本
├── Makefile                    # Make命令集合（推荐使用）
├── README.md                   # 本文档
└── src/                        # ROS工作空间源码目录
```

## ✨ 特性

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

### 1. 配置环境变量

查看并根据需要修改 `docker/.env` 文件：

```bash
# 用户配置（已自动配置为当前主机用户）
USER_NAME=duboping
USER_UID=1000
USER_GID=1000

# Docker镜像配置
IMAGE_NAME=ros-kudan-dev
IMAGE_TAG=latest
CONTAINER_NAME=kudan_ws_container

# ROS版本配置
ROS_DISTRO=noetic

# 工作空间路径
WORKSPACE_DIR=/home/duboping/public/kudan/kudan_ws
```

### 2. 构建 Docker 镜像

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

### 3. 运行容器

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

### 4. 进入容器

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

### 预设别名

容器内已配置以下 bash 别名：

```bash
cm    # catkin_make
cs    # cd ~/catkin_ws/src
cw    # cd ~/catkin_ws
```

### 安装额外依赖

```bash
# 安装 ROS 包
sudo apt-get update
sudo apt-get install ros-noetic-<package-name>

# 使用 rosdep 安装依赖
cd ~/catkin_ws
rosdep install --from-paths src --ignore-src -r -y
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

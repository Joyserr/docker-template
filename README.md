# 通用Docker开发环境模板

这是一个灵活的Docker开发环境模板，可以轻松修改以构建和使用任意类型的Docker镜像。

## 特性

- 🚀 **简单易用** - 只需修改配置文件和Dockerfile即可
- 🔧 **高度可定制** - 支持任意基础镜像和依赖
- 👤 **用户友好** - 自动匹配主机用户，避免权限问题
- 📦 **开箱即用** - 提供常用开发工具和配置
- 🎯 **灵活扩展** - 可根据需要添加任何开发环境

## 快速开始

### 1. 克隆或复制此模板

```bash
git clone <your-repo-url>
cd docker-template
```

### 2. 配置环境变量

编辑 `docker/config/.env` 文件，修改以下参数：

```bash
# 用户配置（与主机用户保持一致）
USER_NAME=your-username
USER_UID=1000
USER_GID=1000

# Docker镜像配置
IMAGE_NAME=my-dev-image
IMAGE_TAG=latest
CONTAINER_NAME=my_dev_container

# 工作空间目录
WORKSPACE_DIR=/path/to/your/workspace
```

### 3. 选择开发环境模板

**方法1：使用模板选择器（推荐）**
```bash
# 交互式选择模板
make template-select

# 直接使用指定模板
make template-use TEMPLATE=python-3.11
```

**方法2：手动复制模板**
```bash
# 复制模板到主Dockerfile
cp docker/templates/python/Dockerfile.3.11 docker/Dockerfile
```

**方法3：手动编写Dockerfile**
编辑 `docker/Dockerfile` 文件，根据需要：
- 修改基础镜像（FROM语句）
- 安装所需的依赖和工具
- 配置开发环境

### 4. 构建镜像

```bash
make build
```

### 5. 运行容器

交互式运行：
```bash
make run
```

后台运行：
```bash
make run-d
```

## 常用命令

### 基础命令

```bash
make help          # 显示帮助信息
make build         # 构建Docker镜像
make run           # 启动容器（交互式）
make run-d         # 启动容器（后台模式）
make stop          # 停止容器
make rm            # 删除容器
make rmi           # 删除镜像
make clean         # 清理容器和镜像
make rebuild       # 重新构建镜像
```

### 容器管理

```bash
make exec CMD='bash'    # 在容器中执行命令
make logs               # 查看容器日志
make ps                 # 查看容器状态
make images             # 查看镜像列表
make bash               # 进入容器bash
make config             # 查看当前配置
```

## 模板示例

项目提供了多种开发环境的Dockerfile模板，位于 `docker/templates/` 目录。每个模板都经过优化，可以直接使用。

### 可用模板

| 模板 | 基础镜像 | 主要工具 | 适用场景 |
|------|---------|---------|---------|
| **ROS2 Humble** | ros:humble | ROS2 Humble, colcon, rviz2 | ROS2开发、机器人仿真、SLAM |
| **ROS2 Foxy** | ros:foxy | ROS2 Foxy, colcon, rviz2 | ROS2开发、机器人仿真、SLAM |
| **Python 3.11** | python:3.11-slim | Python 3.11, pip, jupyter, pytest | Python开发、数据科学、机器学习 |
| **Python 3.12** | python:3.12-slim | Python 3.12, pip, jupyter, pytest | Python开发、数据科学、机器学习 |
| **Node.js 18** | node:18-slim | Node.js 18, npm, yarn, pnpm | Web前端、Node.js后端开发 |
| **Node.js 20** | node:20-slim | Node.js 20, npm, yarn, pnpm | Web前端、Node.js后端开发 |
| **Java 11** | openjdk:11-slim | OpenJDK 11, Maven, Gradle | Java应用开发、Spring Boot |
| **Java 17** | openjdk:17-slim | OpenJDK 17, Maven, Gradle | Java应用开发、Spring Boot |
| **Go 1.22** | golang:1.22-bullseye | Go 1.22, go modules, tools | Go开发、微服务、CLI工具 |
| **Ubuntu通用** | ubuntu:22.04 | Python, Node.js, Go, Java, Docker | 多语言开发、DevOps、全栈开发 |

### 快速使用模板

#### 方法1：直接复制模板

```bash
# 1. 选择并复制模板Dockerfile
cp docker/templates/python/Dockerfile docker/Dockerfile

# 2. （可选）修改Dockerfile以满足特定需求
vim docker/Dockerfile

# 3. 构建镜像
make build

# 4. 运行容器
make run
```

### 方法2：使用模板选择器（推荐）

```bash
# 交互式选择模板
make template-select

# 直接使用指定模板
make template-use TEMPLATE=python-3.11

# 选择模板并构建镜像
make template-build TEMPLATE=nodejs-18

# 选择模板并运行容器
make template-run TEMPLATE=java-17

# 列出所有可用模板
make template-list

# 查看模板详细信息
make template-info TEMPLATE=ros2-humble
```

#### 方法2：基于模板自定义

```bash
# 1. 查看模板内容
cat docker/templates/python/Dockerfile

# 2. 复制到主Dockerfile并修改
cp docker/templates/python/Dockerfile docker/Dockerfile

# 3. 根据项目需求修改Dockerfile
# - 修改基础镜像版本
# - 添加/删除依赖包
# - 配置环境变量

# 4. 构建并运行
make build && make run
```

### 模板详细说明

#### Python开发环境模板

**特点：**
- 基于官方Python 3.11镜像
- 预装常用Python工具（ipython, jupyter, pytest, black等）
- 包含基础开发工具（git, vim, tmux等）
- 已配置Python环境变量和别名

**适用场景：**
- Python Web开发（Django, Flask）
- 数据科学和机器学习
- 自动化脚本开发
- Python包开发

**使用示例：**
```bash
cp docker/templates/python/Dockerfile docker/Dockerfile
make build
make run
```

#### Node.js开发环境模板

**特点：**
- 基于官方Node.js 18镜像
- 预装常用Node.js工具（yarn, pnpm, typescript, eslint等）
- 包含基础开发工具
- 支持TypeScript开发

**适用场景：**
- 前端开发（React, Vue, Angular）
- Node.js后端开发
- 全栈JavaScript开发
- 微服务开发

**使用示例：**
```bash
cp docker/templates/nodejs/Dockerfile docker/Dockerfile
make build
make run
```

#### Java开发环境模板

**特点：**
- 基于OpenJDK 11镜像
- 预装Maven和Gradle构建工具
- 包含基础开发工具
- 已配置Java环境变量

**适用场景：**
- Java应用开发
- Spring Boot项目
- 企业级应用开发
- 微服务开发

**使用示例：**
```bash
cp docker/templates/java/Dockerfile docker/Dockerfile
make build
make run
```

#### ROS开发环境模板

**特点：**
- 基于Ubuntu 20.04
- 完整安装ROS Noetic Desktop Full
- 预装rosdep和常用ROS工具
- 已配置ROS环境变量
- 包含基础开发工具

**适用场景：**
- 机器人软件开发
- ROS应用开发
- 机器人仿真
- SLAM和导航开发

**使用示例：**
```bash
cp docker/templates/ros/Dockerfile docker/Dockerfile
make build
make run
```

**注意：** ROS模板构建时间较长（约15-30分钟），请耐心等待。

### 模板自定义指南

所有模板都遵循相同的结构，便于自定义：

```dockerfile
# 1. 基础镜像（根据需要修改）
FROM <base-image>

# 2. 构建参数（可通过docker build --build-arg传递）
ARG USER_NAME=developer
ARG USER_UID=1000
ARG USER_GID=1000
ARG WORKSPACE_DIR=/home/${USER_NAME}/workspace

# 3. 环境变量
ENV DEBIAN_FRONTEND=noninteractive
ENV TZ=Asia/Shanghai
ENV LANG=C.UTF-8
ENV LC_ALL=C.UTF-8

# 4. 安装依赖和工具
RUN apt-get update && apt-get install -y \
    <your-packages> \
    && apt-get clean

# 5. 创建用户和配置
RUN groupadd -g ${USER_GID} ${USER_NAME} || true
RUN useradd -m -u ${USER_UID} -g ${USER_GID} -s /bin/bash ${USER_NAME} || true

# 6. 切换到用户
USER ${USER_NAME}
WORKDIR ${WORKSPACE_DIR}

# 7. 安装用户级工具和配置
RUN <user-level-installations>

# 8. 自定义配置（.bashrc等）
RUN echo 'alias your-alias="command"' >> ~/.bashrc

# 9. 默认命令
CMD ["tail", "-f", "/dev/null"]
```

### 使用模板

1. 查看模板目录：
```bash
ls docker/templates/
```

2. 复制模板Dockerfile：
```bash
cp docker/templates/python/Dockerfile docker/Dockerfile
```

3. 根据需要修改Dockerfile

4. 构建镜像：
```bash
make build
```

## 自定义配置

### 修改基础镜像

编辑 `docker/Dockerfile`，修改FROM语句：

```dockerfile
# 使用Ubuntu
FROM ubuntu:20.04
FROM ubuntu:22.04

# 使用Debian
FROM debian:11
FROM debian:12

# 使用Alpine Linux（更小体积）
FROM alpine:3.18
FROM alpine:3.19

# 使用官方语言镜像
FROM python:3.11-slim
FROM python:3.12-slim
FROM node:18-slim
FROM node:20-slim
FROM openjdk:11-slim
FROM openjdk:17-slim
```

**建议：**
- 开发环境推荐使用`-slim`版本，体积更小
- 生产环境可以考虑使用`alpine`版本进一步减小体积
- 选择稳定版本（LTS）而非最新版本

### 安装依赖

#### Ubuntu/Debian系统

```dockerfile
# 更新软件源并安装包
RUN apt-get update && apt-get install -y \
    package1 \
    package2 \
    package3 \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

# 安装特定版本
RUN apt-get update && apt-get install -y \
    package1=1.0.0 \
    package2=2.0.0 \
    && apt-get clean
```

#### Alpine系统

```dockerfile
# 安装包
RUN apk add --no-cache \
    package1 \
    package2 \
    package3
```

#### Python包管理

```dockerfile
# 升级pip和基础工具
RUN pip install --upgrade pip setuptools wheel

# 安装Python包
RUN pip install \
    numpy \
    pandas \
    matplotlib \
    requests

# 从requirements.txt安装
COPY requirements.txt .
RUN pip install -r requirements.txt

# 安装到用户目录（推荐）
RUN pip install --user package1 package2
```

#### Node.js包管理

```dockerfile
# 全局安装npm包
RUN npm install -g \
    package1 \
    package2

# 使用yarn
RUN npm install -g yarn
RUN yarn global add package1 package2

# 使用pnpm
RUN npm install -g pnpm
RUN pnpm add -g package1 package2

# 从package.json安装
COPY package.json package-lock.json ./
RUN npm install
```

#### Java依赖管理

```dockerfile
# 使用Maven
COPY pom.xml .
RUN mvn dependency:go-offline

# 使用Gradle
COPY build.gradle .
RUN gradle dependencies
```

### 配置环境变量

#### 在Dockerfile中设置

```dockerfile
# 单个环境变量
ENV MY_VAR=value

# 多个环境变量
ENV VAR1=value1 \
    VAR2=value2 \
    VAR3=value3

# PATH配置
ENV PATH=/custom/path:$PATH

# Python环境
ENV PYTHONPATH=/app:$PYTHONPATH
ENV PYTHONUNBUFFERED=1

# Node.js环境
ENV NODE_ENV=production
ENV npm_config_prefix=/home/user/.npm-global

# Java环境
ENV JAVA_HOME=/usr/lib/jvm/java-11-openjdk-amd64
ENV MAVEN_OPTS="-Xmx1024m"
```

#### 在.env文件中设置

编辑 `docker/config/.env` 文件：

```bash
# 自定义环境变量
ENV_VAR1=value1
ENV_VAR2=value2

# 应用配置
APP_ENV=development
APP_PORT=8080
APP_DEBUG=true

# 数据库配置
DB_HOST=localhost
DB_PORT=5432
DB_NAME=myapp
```

### 端口映射

#### 方法1：在.env文件中配置

编辑 `docker/config/.env` 文件：

```bash
# 端口映射（主机端口:容器端口）
PORTS=8080:8080 3000:3000 5000:5000
```

#### 方法2：在运行脚本中添加

编辑 `docker/scripts/run/docker-run.sh`：

```bash
docker run -it --rm \
    --name ${CONTAINER_NAME} \
    -p 8080:8080 \
    -p 3000:3000 \
    -v ${WORKSPACE_DIR}:/home/${USER_NAME}/workspace \
    ${IMAGE_NAME}:${IMAGE_TAG}
```

### 卷挂载

#### 挂载工作目录

```bash
# 在.env中配置
WORKSPACE_DIR=/path/to/your/workspace

# 在运行脚本中使用
-v ${WORKSPACE_DIR}:/home/${USER_NAME}/workspace
```

#### 挂载其他目录

```bash
# 挂载数据目录
-v /path/to/data:/data

# 挂载配置文件
-v /path/to/config:/config:ro

# 挂载多个目录
-v /path/to/dir1:/dir1 \
-v /path/to/dir2:/dir2
```

### GPU支持

如果需要GPU支持，确保已安装nvidia-docker：

#### 检查nvidia-docker安装

```bash
docker run --rm --gpus all nvidia/cuda:11.0.3-base-ubuntu20.04 nvidia-smi
```

#### 在运行脚本中启用GPU

编辑 `docker/scripts/run/docker-run.sh`：

```bash
docker run -it --rm \
    --name ${CONTAINER_NAME} \
    --gpus all \
    -v ${WORKSPACE_DIR}:/home/${USER_NAME}/workspace \
    ${IMAGE_NAME}:${IMAGE_TAG}
```

#### 指定GPU数量

```bash
# 使用所有GPU
--gpus all

# 使用特定GPU
--gpus device=0,1

# 使用特定数量的GPU
--gpus 2
```

### 网络配置

#### 使用主机网络

```bash
docker run -it --rm \
    --name ${CONTAINER_NAME} \
    --network host \
    -v ${WORKSPACE_DIR}:/home/${USER_NAME}/workspace \
    ${IMAGE_NAME}:${IMAGE_TAG}
```

#### 自定义网络

```bash
# 创建自定义网络
docker network create my-network

# 使用自定义网络
docker run -it --rm \
    --name ${CONTAINER_NAME} \
    --network my-network \
    -v ${WORKSPACE_DIR}:/home/${USER_NAME}/workspace \
    ${IMAGE_NAME}:${IMAGE_TAG}
```

### 资源限制

#### 限制内存使用

```bash
docker run -it --rm \
    --name ${CONTAINER_NAME} \
    --memory="4g" \
    --memory-swap="4g" \
    -v ${WORKSPACE_DIR}:/home/${USER_NAME}/workspace \
    ${IMAGE_NAME}:${IMAGE_TAG}
```

#### 限制CPU使用

```bash
docker run -it --rm \
    --name ${CONTAINER_NAME} \
    --cpus="2.0" \
    -v ${WORKSPACE_DIR}:/home/${USER_NAME}/workspace \
    ${IMAGE_NAME}:${IMAGE_TAG}
```

#### 综合资源限制

```bash
docker run -it --rm \
    --name ${CONTAINER_NAME} \
    --memory="4g" \
    --cpus="2.0" \
    --pids-limit 1024 \
    -v ${WORKSPACE_DIR}:/home/${USER_NAME}/workspace \
    ${IMAGE_NAME}:${IMAGE_TAG}
```

## 多架构构建

本模板支持为多种CPU架构构建Docker镜像，包括：
- **linux/amd64**: Intel/AMD 64位架构 (x86_64)
- **linux/arm64**: ARM 64位架构 (aarch64)
- **linux/arm/v7**: ARM 32位架构
- **linux/riscv64**: RISC-V 64位架构

### 快速开始

#### 1. 设置Buildx构建器

```bash
make setup-buildx
```

此命令会：
- 创建或使用名为`multiarch-builder`的Buildx构建器
- 安装QEMU模拟器以支持交叉编译
- 显示构建器信息

#### 2. 列出支持的平台

```bash
make list-platforms
```

#### 3. 构建多架构镜像

**构建所有配置的平台：**

```bash
make build-multiarch
```

**构建特定架构：**

```bash
# 仅构建AMD64
make build-amd64

# 仅构建ARM64
make build-arm64

# 构建所有支持的架构
make build-all
```

### 配置多架构构建

编辑 `docker/config/.env.multiarch` 文件：

```bash
# 选择目标平台
TARGET_PLATFORMS="linux/amd64 linux/arm64"

# 构建输出类型
BUILD_OUTPUT_TYPE=local  # local, registry, tar

# 镜像仓库配置（当BUILD_OUTPUT_TYPE=registry时）
REGISTRY=docker.io
REPO_NAME=yourusername/my-dev-image

# 输出路径（当BUILD_OUTPUT_TYPE=tar时）
OUTPUT_PATH=./output/images
```

### 构建输出类型

#### 本地存储（默认）

```bash
make build-multiarch
```

镜像将保存到本地Docker镜像存储中。

#### 推送到镜像仓库

编辑 `.env.multiarch`：

```bash
BUILD_OUTPUT_TYPE=registry
REGISTRY=docker.io
REPO_NAME=yourusername/my-dev-image
```

然后运行：

```bash
make build-multiarch
# 或直接推送
make push-multiarch
```

#### 导出为tar文件

编辑 `.env.multiarch`：

```bash
BUILD_OUTPUT_TYPE=tar
OUTPUT_PATH=./output/images
```

然后运行：

```bash
make build-multiarch
```

### 导入/导出镜像

```bash
# 导出镜像为tar
make export-tar

# 从tar文件导入镜像
make import-tar TAR_FILE=./output/images/my-dev-image-latest.tar
```

### 查看多架构镜像信息

```bash
make inspect-multiarch
```

### 常见问题

#### Q: 如何在ARM设备上运行x86镜像？

A: 需要启用QEMU模拟器，`make setup-buildx`命令会自动处理。

#### Q: 多架构构建需要多长时间？

A: 取决于镜像复杂度和网络速度，通常比单平台构建慢2-4倍。

#### Q: 如何验证镜像是否支持多架构？

A: 使用 `make inspect-multiarch` 查看镜像的平台信息。

### 详细文档

更多详细信息请参考：[docker/MULTIARCH.md](docker/MULTIARCH.md)

## 工作目录说明

容器启动后，主机的工作空间目录会被挂载到容器的 `/home/{USER_NAME}/workspace` 目录。

- 主机目录：`WORKSPACE_DIR`（在.env中配置）
- 容器目录：`/home/{USER_NAME}/workspace`

这样可以在容器内外共享文件，修改会实时同步。

## 常见问题

### 权限问题

如果遇到文件权限问题，确保 `.env` 文件中的 `USER_UID` 和 `USER_GID` 与主机用户一致：

```bash
id  # 查看当前用户的UID和GID
```

### 容器无法启动

检查Dockerfile语法是否正确：

```bash
docker build -f docker/Dockerfile -t test .
```

### 镜像构建失败

查看详细错误信息：

```bash
docker build --no-cache -f docker/Dockerfile -t test .
```

### X11转发不工作

确保主机启用了X11转发：

```bash
xhost +local:docker
```

## 项目结构

```
docker-template/
├── Makefile                 # 主Makefile
├── README.md               # 项目文档
└── docker/
    ├── Dockerfile          # Docker镜像定义（主要修改文件）
    ├── config/
    │   └── .env           # 环境变量配置（主要修改文件）
    ├── scripts/
    │   ├── build/
    │   │   └── docker-build.sh      # 构建脚本
    │   ├── run/
    │   │   ├── docker-run.sh       # 运行脚本（交互式）
    │   │   └── docker-run-detach.sh # 运行脚本（后台模式）
    │   └── utils/
    │       └── common.sh          # 公共函数
    └── templates/          # 各种语言的Dockerfile示例
        ├── python/
        ├── nodejs/
        ├── java/
        └── ros/
```

## 贡献

欢迎提交问题和改进建议！

## 许可证

MIT License

## 联系方式

如有问题，请提交Issue或联系维护者。

# Docker多架构镜像构建指南

本文档详细说明如何使用Docker Buildx构建多架构Docker镜像，支持同时为不同的CPU架构和平台构建镜像。

## 📋 目录

- [概述](#概述)
- [系统要求](#系统要求)
- [快速开始](#快速开始)
- [配置说明](#配置说明)
- [构建方法](#构建方法)
- [平台选择](#平台选择)
- [常见问题](#常见问题)
- [最佳实践](#最佳实践)

## 概述

本模板支持为以下架构构建Docker镜像：

- **linux/amd64**: Intel/AMD 64位架构 (x86_64)
- **linux/arm64**: ARM 64位架构 (aarch64)
- **linux/arm/v7**: ARM 32位架构 (armv7)
- **linux/riscv64**: RISC-V 64位架构

## 系统要求

### Docker版本要求

- Docker Engine 19.03 或更高版本
- 启用Buildx实验性功能（Docker 20.10+已默认启用）

### 检查Docker版本

```bash
docker --version
docker buildx version
```

### 操作系统支持

- Linux (推荐)
- macOS
- Windows (WSL2)

## 快速开始

### 🚀 5分钟快速上手

#### 前置条件检查

```bash
# 1. 检查Docker版本（需要19.03+）
docker --version

# 2. 检查Buildx是否可用
docker buildx version

# 3. 如果Buildx不可用，启用实验性功能（Docker 19.03-20.10）
export DOCKER_CLI_EXPERIMENTAL=enabled
```

#### 快速构建步骤

**方法1: 使用Makefile（推荐）**

```bash
# 1. 初始化环境
make init

# 2. 设置Buildx构建器
make setup-buildx

# 3. 构建多架构镜像
make build-multiarch

# 4. 查看构建结果
docker images | grep ros-kudan-dev
```

**方法2: 使用交互式脚本**

```bash
# 1. 选择目标平台
./docker/scripts/utils/select-platform.sh

# 2. 构建镜像
./docker/scripts/build/docker-build-multiarch.sh
```

**方法3: 单独构建特定架构**

```bash
# 仅构建AMD64镜像
make build-amd64

# 仅构建ARM64镜像
make build-arm64

# 构建所有架构
make build-all
```

#### 支持的架构

| 架构 | 平台标识 | 说明 |
|------|---------|------|
| AMD64 | linux/amd64 | Intel/AMD 64位 (x86_64) |
| ARM64 | linux/arm64 | ARM 64位 (aarch64) |
| ARMv7 | linux/arm/v7 | ARM 32位 |
| RISC-V | linux/riscv64 | RISC-V 64位 |

#### 配置目标平台

**方式1: 交互式选择**

```bash
./docker/scripts/utils/select-platform.sh
```

**方式2: 手动编辑配置**

编辑 `docker/config/.env.multiarch` 文件：

```bash
# 选择单个平台
TARGET_PLATFORMS="linux/amd64"

# 选择多个平台
TARGET_PLATFORMS="linux/amd64 linux/arm64"

# 选择所有平台
TARGET_PLATFORMS="linux/amd64 linux/arm64 linux/arm/v7 linux/riscv64"
```

#### 构建输出类型

在 `docker/config/.env.multiarch` 中配置：

```bash
# 保存到本地Docker镜像存储（默认）
BUILD_OUTPUT_TYPE=local

# 推送到Docker Hub或其他镜像仓库
BUILD_OUTPUT_TYPE=registry
REGISTRY=docker.io
REPO_NAME=yourusername/ros-kudan-dev

# 导出为tar文件
BUILD_OUTPUT_TYPE=tar
OUTPUT_PATH=./output/images
```

#### 常用命令

**查看帮助**

```bash
make help
```

**构建相关**

```bash
make build-multiarch    # 构建多架构镜像
make build-amd64        # 构建AMD64镜像
make build-arm64        # 构建ARM64镜像
make build-all          # 构建所有架构
```

**运行相关**

```bash
make run                # 运行默认架构容器
make run-amd64          # 运行AMD64容器
make run-arm64          # 运行ARM64容器
make run-multiarch      # 使用多架构配置运行
```

**管理相关**

```bash
make setup-buildx       # 设置Buildx构建器
make list-platforms     # 列出支持的平台
make export-tar         # 导出镜像为tar
make import-tar TAR_FILE=path/to/image.tar  # 导入镜像
```

#### 验证构建结果

```bash
# 查看本地镜像
docker images | grep ros-kudan-dev

# 查看镜像的架构信息
docker buildx imagetools inspect ros-kudan-dev:latest

# 测试运行镜像
docker run --rm -it ros-kudan-dev:latest-amd64 uname -m
docker run --rm -it ros-kudan-dev:latest-arm64 uname -m

# 验证ROS环境
docker run --rm -it ros-kudan-dev:latest rosversion -d
```

---

### 详细步骤

#### 1. 初始化环境

```bash
# 克隆仓库后，进入项目目录
cd /path/to/docker-template

# 初始化环境配置
make init
```

### 2. 选择目标平台

```bash
# 使用交互式脚本选择平台
./docker/scripts/utils/select-platform.sh
```

### 3. 构建多架构镜像

```bash
# 方法1: 使用Makefile
make build-multiarch

# 方法2: 直接使用脚本
./docker/scripts/build/docker-build-multiarch.sh

# 方法3: 使用docker-compose
docker-compose -f docker/docker-compose.multiarch.yml build
```

## 配置说明

### 环境变量配置

多架构构建的配置位于 `docker/.env.multiarch` 文件中：

```bash
# 构建器名称
BUILDER_NAME=multiarch-builder

# 目标平台（空格分隔）
TARGET_PLATFORMS="linux/amd64 linux/arm64"

# 构建输出类型
BUILD_OUTPUT_TYPE=local  # 可选: local, registry, docker, tar

# 镜像仓库配置（当BUILD_OUTPUT_TYPE=registry时）
REGISTRY=docker.io
REPO_NAME=yourusername/ros-kudan-dev

# 输出文件路径（当BUILD_OUTPUT_TYPE=tar时）
OUTPUT_PATH=./output/images

# 是否使用缓存
BUILD_CACHE=true
```

### 输出类型说明

| 类型 | 说明 | 使用场景 |
|------|------|----------|
| `local` | 保存到本地Docker镜像存储 | 本地开发和测试 |
| `registry` | 推送到Docker Hub或其他镜像仓库 | 生产环境部署 |
| `docker` | 直接加载到本地Docker（仅单平台） | 快速构建和测试 |
| `tar` | 导出为tar文件 | 离线部署和分发 |

## 构建方法

### 方法1: 使用Makefile（推荐）

```bash
# 查看所有可用命令
make help

# 构建多架构镜像
make build-multiarch

# 构建特定架构镜像
make build-amd64    # 仅构建AMD64
make build-arm64    # 仅构建ARM64

# 构建所有支持的架构
make build-all

# 设置Docker Buildx构建器
make setup-buildx

# 列出支持的平台
make list-platforms
```

### 方法2: 使用构建脚本

```bash
# 直接运行多架构构建脚本
./docker/scripts/build/docker-build-multiarch.sh

# 脚本会自动：
# 1. 检查Docker Buildx是否可用
# 2. 创建或使用现有的构建器
# 3. 构建指定平台的多架构镜像
# 4. 创建manifest列表
# 5. 显示构建结果
```

### 方法3: 使用docker-compose

```bash
# 构建所有平台
docker-compose -f docker/docker-compose.multiarch.yml build

# 构建特定平台
docker-compose -f docker/docker-compose.multiarch.yml build ros-dev-amd64
docker-compose -f docker/docker-compose.multiarch.yml build ros-dev-arm64

# 运行特定平台的容器
docker-compose -f docker/docker-compose.multiarch.yml --profile amd64 up -d
docker-compose -f docker/docker-compose.multiarch.yml --profile arm64 up -d
```

### 方法4: 直接使用docker buildx

```bash
# 创建构建器
docker buildx create --name multiarch-builder --driver docker-container --use
docker buildx inspect --bootstrap

# 构建多架构镜像
docker buildx build \
    --platform linux/amd64,linux/arm64 \
    --build-arg ROS_DISTRO=noetic \
    --build-arg USER_NAME=duboping \
    --build-arg USER_UID=1000 \
    --build-arg USER_GID=1000 \
    -f docker/Dockerfile \
    -t ros-kudan-dev:latest \
    --load \
    .
```

## 平台选择

### 交互式选择

使用平台选择脚本进行交互式选择：

```bash
./docker/scripts/utils/select-platform.sh
```

脚本会显示：
1. 当前系统信息
2. 可用目标平台列表
3. 选择单个平台、所有平台或自定义组合
4. 自动更新配置文件

### 手动配置

直接编辑 `docker/.env.multiarch` 文件：

```bash
# 选择单个平台
TARGET_PLATFORMS="linux/amd64"

# 选择多个平台
TARGET_PLATFORMS="linux/amd64 linux/arm64"

# 选择所有平台
TARGET_PLATFORMS="linux/amd64 linux/arm64 linux/arm/v7 linux/riscv64"
```

## 常见问题

### 1. Docker Buildx未安装或不可用

**错误信息:**
```
Docker Buildx未安装或不可用
```

**解决方案:**
```bash
# 检查Docker版本
docker --version

# 如果版本低于19.03，请升级Docker
# 对于Docker 19.03-20.10，需要启用Buildx实验性功能
export DOCKER_CLI_EXPERIMENTAL=enabled

# 验证Buildx是否可用
docker buildx version
```

### 2. QEMU模拟器未安装

**错误信息:**
```
failed to solve: executor failed running [/bin/sh -c ...]: no matching manifest for linux/arm64 in the manifest list entries
```

**解决方案:**
```bash
# 安装QEMU模拟器（Linux）
docker run --privileged --rm tonistiigi/binfmt --install all

# 验证QEMU是否安装
docker run --rm --privileged multiarch/qemu-user-static --reset -p yes
```

### 3. 构建速度慢

**原因:** 交叉编译使用QEMU模拟器，速度较慢

**解决方案:**
```bash
# 使用本地缓存
docker buildx build \
    --cache-from type=registry,ref=ros-kudan-dev:buildcache \
    --cache-to type=registry,ref=ros-kudan-dev:buildcache,mode=max \
    ...

# 使用BuildKit缓存挂载
# 在Dockerfile中使用 --mount=type=cache
```

### 4. 镜像推送到仓库失败

**错误信息:**
```
unauthorized: authentication required
```

**解决方案:**
```bash
# 登录到Docker Hub
docker login

# 或登录到私有仓库
docker login registry.example.com

# 然后重新构建
make build-multiarch
```

### 5. 权限问题

**错误信息:**
```
permission denied while trying to connect to the Docker daemon socket
```

**解决方案:**
```bash
# 将用户添加到docker组
sudo usermod -aG docker $USER

# 重新登录或执行
newgrp docker
```

## 最佳实践

### 1. 使用缓存加速构建

```bash
# 在.env.multiarch中启用缓存
BUILD_CACHE=true

# 使用registry缓存
docker buildx build \
    --cache-from type=registry,ref=ros-kudan-dev:buildcache \
    --cache-to type=registry,ref=ros-kudan-dev:buildcache,mode=max \
    ...
```

### 2. 并行构建

```bash
# 在.env.multiarch中设置构建并发数
BUILD_JOBS=4
```

### 3. 分层构建优化

```dockerfile
# 在Dockerfile中，将不常变化的层放在前面
# 将经常变化的层放在后面

# 好的做法
FROM ros:noetic-ros-base
RUN apt-get update && apt-get install -y ...  # 基础依赖
COPY requirements.txt /tmp/
RUN pip install -r /tmp/requirements.txt     # Python依赖
COPY . .                                     # 应用代码（最后）
```

### 4. 使用多阶段构建

```dockerfile
# 构建阶段
FROM ros:noetic-ros-base AS builder
WORKDIR /build
COPY . .
RUN make build

# 运行阶段
FROM ros:noetic-ros-base
COPY --from=builder /build /app
```

### 5. 镜像标签管理

```bash
# 使用语义化版本
IMAGE_TAG=1.0.0

# 添加架构后缀
IMAGE_TAG=1.0.0-amd64
IMAGE_TAG=1.0.0-arm64

# 使用latest标签
IMAGE_TAG=latest
```

## 高级用法

### 1. 创建Manifest列表

```bash
# 手动创建manifest列表
docker buildx imagetools create \
    --tag ros-kudan-dev:latest \
    ros-kudan-dev:latest-amd64 \
    ros-kudan-dev:latest-arm64

# 查看manifest列表
docker buildx imagetools inspect ros-kudan-dev:latest
```

### 2. 导出和导入镜像

```bash
# 导出镜像为tar文件
make export-tar

# 从tar文件导入镜像
make import-tar TAR_FILE=./output/images/ros-kudan-dev-latest.tar
```

### 3. 使用私有仓库

```bash
# 在.env.multiarch中配置
REGISTRY=registry.example.com
REPO_NAME=myorg/ros-kudan-dev
BUILD_OUTPUT_TYPE=registry

# 登录到私有仓库
docker login registry.example.com

# 构建并推送
make build-multiarch
```

## 验证构建结果

### 检查镜像

```bash
# 查看本地镜像
docker images | grep ros-kudan-dev

# 查看镜像的架构信息
docker buildx imagetools inspect ros-kudan-dev:latest
```

### 测试运行

```bash
# 运行AMD64镜像
docker run --rm -it ros-kudan-dev:latest-amd64 uname -m

# 运行ARM64镜像
docker run --rm -it ros-kudan-dev:latest-arm64 uname -m

# 验证ROS环境
docker run --rm -it ros-kudan-dev:latest rosversion -d
```

## 参考资源

- [Docker Buildx官方文档](https://docs.docker.com/buildx/working-with-buildx/)
- [多架构构建最佳实践](https://www.docker.com/blog/multi-arch-images/)
- [Dockerfile最佳实践](https://docs.docker.com/develop/develop-images/dockerfile_best-practices/)
- [QEMU用户模式模拟](https://www.qemu.org/docs/master/system/target-i386.html)

## 支持

如有问题，请查看：
1. 本文档的常见问题部分
2. 项目的README.md
3. 提交Issue到项目仓库

## 更新日志

### v1.0.0 (2024-01-XX)
- 初始版本
- 支持AMD64、ARM64、ARMv7、RISC-V架构
- 提供交互式平台选择
- 支持多种输出类型
- 完整的Makefile集成

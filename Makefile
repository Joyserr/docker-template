# ========================================
# ROS Noetic Docker 开发环境 Makefile
# ========================================
# 本Makefile作为统一的命令入口，所有目标都调用docker/scripts/下的对应脚本
# 这样可以确保功能实现的一致性和可维护性

# 加载环境变量（从docker/config目录）
include docker/config/.env
export

# Docker相关文件路径
DOCKER_DIR := docker
DOCKERFILE := $(DOCKER_DIR)/Dockerfile
COMPOSE_FILE := $(DOCKER_DIR)/docker-compose.yml
MULTIARCH_ENV_FILE := $(DOCKER_DIR)/config/.env.multiarch
SCRIPTS_DIR := $(DOCKER_DIR)/scripts

# 脚本路径
INIT_SCRIPT := $(SCRIPTS_DIR)/utils/init-env.sh
BUILD_SCRIPT := $(SCRIPTS_DIR)/build/docker-build.sh
BUILD_MULTIARCH_SCRIPT := $(SCRIPTS_DIR)/build/docker-build-multiarch.sh
REBUILD_SCRIPT := $(SCRIPTS_DIR)/build/docker-rebuild.sh
RUN_SCRIPT := $(SCRIPTS_DIR)/run/docker-run.sh
RUN_DETACH_SCRIPT := $(SCRIPTS_DIR)/run/docker-run-detach.sh
EXEC_SCRIPT := $(SCRIPTS_DIR)/run/docker-exec.sh
STOP_SCRIPT := $(SCRIPTS_DIR)/run/docker-stop.sh
CLEAN_SCRIPT := $(SCRIPTS_DIR)/run/docker-clean.sh
LOGS_SCRIPT := $(SCRIPTS_DIR)/run/docker-logs.sh
STATUS_SCRIPT := $(SCRIPTS_DIR)/run/docker-status.sh

.PHONY: help init build build-multiarch run run-detach exec stop clean rebuild logs shell status ps

# 默认目标
.DEFAULT_GOAL := help

help: ## 显示帮助信息
	@echo "ROS Noetic Docker 开发环境"
	@echo ""
	@echo "可用命令："
	@grep -hE '^[a-zA-Z_-]+:.*?## .*$$' Makefile | sort | awk 'BEGIN {FS = ":.*?## "}; {printf "  \033[36m%-25s\033[0m %s\n", $$1, $$2}'
	@echo ""
	@echo "环境配置："
	@echo "  镜像名称: $(IMAGE_NAME):$(IMAGE_TAG)"
	@echo "  容器名称: $(CONTAINER_NAME)"
	@echo "  ROS版本:  $(ROS_DISTRO)"
	@echo "  用户信息: $(USER_NAME) (UID=$(USER_UID), GID=$(USER_GID))"

init: ## 初始化环境配置（自动检测系统信息）
	@$(INIT_SCRIPT)

build: ## 构建Docker镜像
	@$(BUILD_SCRIPT)

run: ## 运行容器（交互式，退出后自动删除）
	@$(RUN_SCRIPT)

run-detach: ## 后台运行容器
	@$(RUN_DETACH_SCRIPT)

exec: ## 进入运行中的容器
	@$(EXEC_SCRIPT)

stop: ## 停止并删除容器
	@$(STOP_SCRIPT)

clean: ## 清理容器和镜像
	@$(CLEAN_SCRIPT)

rebuild: ## 清理并重新构建镜像
	@$(REBUILD_SCRIPT)

logs: ## 查看容器日志
	@$(LOGS_SCRIPT)

shell: ## 运行容器并进入shell（run的别名）
	@$(RUN_SCRIPT)

status: ## 查看容器状态
	@$(STATUS_SCRIPT)

ps: ## 查看容器状态（status的别名）
	@$(STATUS_SCRIPT)

# ========================================
# 多架构相关命令
# ========================================

build-multiarch: ## 构建多架构Docker镜像（使用Docker Buildx）
	@$(BUILD_MULTIARCH_SCRIPT)

build-amd64: ## 构建AMD64架构镜像
	@echo "==> 构建AMD64架构镜像: $(IMAGE_NAME):$(IMAGE_TAG)-amd64"
	@docker buildx build \
		--build-arg ROS_DISTRO=$(ROS_DISTRO) \
		--build-arg USER_NAME=$(USER_NAME) \
		--build-arg USER_UID=$(USER_UID) \
		--build-arg USER_GID=$(USER_GID) \
		--build-arg TARGETPLATFORM=linux/amd64 \
		--platform linux/amd64 \
		-f $(DOCKERFILE) \
		-t $(IMAGE_NAME):$(IMAGE_TAG)-amd64 \
		--load \
		$(DOCKER_DIR)

build-arm64: ## 构建ARM64架构镜像
	@echo "==> 构建ARM64架构镜像: $(IMAGE_NAME):$(IMAGE_TAG)-arm64"
	@docker buildx build \
		--build-arg ROS_DISTRO=$(ROS_DISTRO) \
		--build-arg USER_NAME=$(USER_NAME) \
		--build-arg USER_UID=$(USER_UID) \
		--build-arg USER_GID=$(USER_GID) \
		--build-arg TARGETPLATFORM=linux/arm64 \
		--platform linux/arm64 \
		-f $(DOCKERFILE) \
		-t $(IMAGE_NAME):$(IMAGE_TAG)-arm64 \
		--load \
		$(DOCKER_DIR)

build-all: ## 构建所有支持的架构镜像
	@echo "==> 构建所有支持的架构镜像"
	@$(MAKE) build-amd64
	@$(MAKE) build-arm64

run-multiarch: ## 使用多架构配置运行容器
	@echo "==> 启动多架构容器: $(CONTAINER_NAME)"
	@xhost +local:docker > /dev/null 2>&1 || true
	@docker-compose -f $(COMPOSE_FILE) --profile default up -d

run-amd64: ## 运行AMD64架构容器
	@echo "==> 启动AMD64架构容器: $(CONTAINER_NAME)-amd64"
	@xhost +local:docker > /dev/null 2>&1 || true
	@docker-compose -f $(COMPOSE_FILE) --profile amd64 up -d

run-arm64: ## 运行ARM64架构容器
	@echo "==> 启动ARM64架构容器: $(CONTAINER_NAME)-arm64"
	@xhost +local:docker > /dev/null 2>&1 || true
	@docker-compose -f $(COMPOSE_FILE) --profile arm64 up -d

# ========================================
# Docker Buildx管理命令
# ========================================

setup-buildx: ## 设置Docker Buildx构建器
	@echo "==> 设置Docker Buildx构建器"
	@if ! docker buildx inspect multiarch-builder >/dev/null 2>&1; then \
		docker buildx create --name multiarch-builder --driver docker-container --use; \
	else \
		docker buildx use multiarch-builder; \
	fi
	@docker buildx inspect --bootstrap
	@echo "==> 构建器设置完成"

list-platforms: ## 列出支持的平台
	@echo "==> 支持的目标平台:"
	@echo "  - linux/amd64 (Intel/AMD 64位)"
	@echo "  - linux/arm64 (ARM 64位)"
	@echo "  - linux/arm/v7 (ARM 32位)"
	@echo ""
	@echo "当前系统架构:"
	@uname -m

push-multiarch: ## 推送多架构镜像到仓库
	@echo "==> 推送多架构镜像到仓库"
	@$(BUILD_MULTIARCH_SCRIPT)

export-tar: ## 导出镜像为tar文件
	@echo "==> 导出镜像为tar文件"
	@mkdir -p ./output/images
	@docker save $(IMAGE_NAME):$(IMAGE_TAG) -o ./output/images/$(IMAGE_NAME)-$(IMAGE_TAG).tar
	@echo "==> 镜像已导出到: ./output/images/$(IMAGE_NAME)-$(IMAGE_TAG).tar"

import-tar: ## 从tar文件导入镜像
	@echo "==> 从tar文件导入镜像"
	@if [ -z "$(TAR_FILE)" ]; then \
		echo "错误: 请指定TAR_FILE参数"; \
		echo "用法: make import-tar TAR_FILE=path/to/image.tar"; \
		exit 1; \
	fi
	@docker load -i $(TAR_FILE)
	@echo "==> 镜像导入完成"

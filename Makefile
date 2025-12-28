# ========================================
# 通用Docker开发环境模板 Makefile
# ========================================

# 默认目标
.PHONY: help
help:
	@echo "========================================="
	@echo "通用Docker开发环境模板"
	@echo "========================================="
	@echo ""
	@echo "快速开始:"
	@echo "  1. 编辑 docker/Dockerfile 配置基础镜像和依赖"
	@echo "  2. 编辑 docker/config/.env 配置环境变量"
	@echo "  3. 运行 'make build' 构建镜像"
	@echo "  4. 运行 'make run' 启动容器"
	@echo ""
	@echo "基础命令:"
	@echo "  make build          - 构建Docker镜像"
	@echo "  make run            - 启动容器（交互式）"
	@echo "  make run-d          - 启动容器（后台模式）"
	@echo "  make stop           - 停止容器"
	@echo "  make rm             - 删除容器"
	@echo "  make rmi            - 删除镜像"
	@echo "  make clean          - 清理容器和镜像"
	@echo "  make exec CMD='cmd' - 在运行中的容器中执行命令"
	@echo "  make logs           - 查看容器日志"
	@echo "  make ps             - 查看容器状态"
	@echo "  make images         - 查看镜像列表"
	@echo ""
	@echo "多架构构建命令:"
	@echo "  make setup-buildx       - 设置Buildx构建器"
	@echo "  make build-multiarch    - 构建多架构镜像"
	@echo "  make build-amd64        - 构建AMD64镜像"
	@echo "  make build-arm64        - 构建ARM64镜像"
	@echo "  make build-all          - 构建所有架构"
	@echo "  make list-platforms     - 列出支持的平台"
	@echo "  make export-tar         - 导出镜像为tar"
	@echo "  make import-tar TAR_FILE=path/to/image.tar  - 导入镜像"
	@echo ""
	@echo "配置文件:"
	@echo "  docker/Dockerfile       - Docker镜像定义"
	@echo "  docker/config/.env      - 环境变量配置"
	@echo "  docker/config/.env.multiarch - 多架构构建配置"
	@echo ""
	@echo "模板示例:"
	@echo "  docker/templates/       - 各种语言的Dockerfile示例"
	@echo ""

# 加载环境变量
-include docker/config/.env

# 设置默认值
USER_NAME ?= $(shell whoami)
USER_UID ?= $(shell id -u)
USER_GID ?= $(shell id -g)
IMAGE_NAME ?= my-dev-image
IMAGE_TAG ?= latest
CONTAINER_NAME ?= my_dev_container
WORKSPACE_DIR ?= $(shell pwd)

# 颜色定义
GREEN := \033[0;32m
YELLOW := \033[1;33m
RED := \033[0;31m
NC := \033[0m # No Color

# 构建镜像
.PHONY: build
build:
	@echo "$(GREEN)=========================================$(NC)"
	@echo "$(GREEN)构建Docker镜像$(NC)"
	@echo "$(GREEN)=========================================$(NC)"
	@docker/scripts/build/docker-build.sh

# 运行容器（交互式）
.PHONY: run
run:
	@echo "$(GREEN)=========================================$(NC)"
	@echo "$(GREEN)启动容器（交互式）$(NC)"
	@echo "$(GREEN)=========================================$(NC)"
	@docker/scripts/run/docker-run.sh

# 运行容器（后台模式）
.PHONY: run-d
run-d:
	@echo "$(GREEN)=========================================$(NC)"
	@echo "$(GREEN)启动容器（后台模式）$(NC)"
	@echo "$(GREEN)=========================================$(NC)"
	@docker/scripts/run/docker-run-detach.sh

# 停止容器
.PHONY: stop
stop:
	@echo "$(YELLOW)停止容器: $(CONTAINER_NAME)$(NC)"
	@docker stop $(CONTAINER_NAME) 2>/dev/null || true

# 删除容器
.PHONY: rm
rm:
	@echo "$(YELLOW)删除容器: $(CONTAINER_NAME)$(NC)"
	@docker rm -f $(CONTAINER_NAME) 2>/dev/null || true

# 删除镜像
.PHONY: rmi
rmi:
	@echo "$(RED)删除镜像: $(IMAGE_NAME):$(IMAGE_TAG)$(NC)"
	@docker rmi -f $(IMAGE_NAME):$(IMAGE_TAG) 2>/dev/null || true

# 清理容器和镜像
.PHONY: clean
clean: stop rm
	@echo "$(RED)清理容器和镜像$(NC)"
	@docker rmi -f $(IMAGE_NAME):$(IMAGE_TAG) 2>/dev/null || true

# 在运行中的容器中执行命令
.PHONY: exec
exec:
	@if [ -z "$(CMD)" ]; then \
		echo "$(RED)错误: 请指定要执行的命令$(NC)"; \
		echo "用法: make exec CMD='bash'"; \
		exit 1; \
	fi
	@echo "$(GREEN)在容器中执行命令: $(CMD)$(NC)"
	@docker exec -it $(CONTAINER_NAME) $(CMD)

# 查看容器日志
.PHONY: logs
logs:
	@docker logs -f $(CONTAINER_NAME)

# 查看容器状态
.PHONY: ps
ps:
	@docker ps -a | grep $(CONTAINER_NAME) || echo "容器 $(CONTAINER_NAME) 不存在"

# 查看镜像列表
.PHONY: images
images:
	@docker images | grep $(IMAGE_NAME) || echo "镜像 $(IMAGE_NAME) 不存在"

# 重新构建镜像
.PHONY: rebuild
rebuild: clean build
	@echo "$(GREEN)重新构建完成$(NC)"

# 进入容器bash
.PHONY: bash
bash:
	@docker exec -it $(CONTAINER_NAME) bash

# 查看配置
.PHONY: config
config:
	@echo "========================================="
	@echo "当前配置"
	@echo "========================================="
	@echo "用户名称: $(USER_NAME)"
	@echo "用户UID:  $(USER_UID)"
	@echo "用户GID:  $(USER_GID)"
	@echo "镜像名称: $(IMAGE_NAME):$(IMAGE_TAG)"
	@echo "容器名称: $(CONTAINER_NAME)"
	@echo "工作空间: $(WORKSPACE_DIR)"
	@echo "========================================="

# ========================================
# 多架构构建命令
# ========================================

# 加载多架构配置
-include docker/config/.env.multiarch

# 设置多架构构建默认值
BUILDER_NAME ?= multiarch-builder
TARGET_PLATFORMS ?= linux/amd64 linux/arm64
BUILD_OUTPUT_TYPE ?= local
REGISTRY ?= docker.io
REPO_NAME ?= $(IMAGE_NAME)
OUTPUT_PATH ?= ./output/images
BUILD_CACHE ?= true
ENABLE_QEMU ?= true

# 设置Buildx构建器
.PHONY: setup-buildx
setup-buildx:
	@echo "$(GREEN)=========================================$(NC)"
	@echo "$(GREEN)设置Buildx构建器$(NC)"
	@echo "$(GREEN)=========================================$(NC)"
	@echo "创建构建器: $(BUILDER_NAME)"
	@docker buildx create --name $(BUILDER_NAME) --use --bootstrap 2>/dev/null || \
		docker buildx use $(BUILDER_NAME) 2>/dev/null || \
		docker buildx use default
	@echo "检查QEMU支持..."
	@docker run --privileged --rm tonistiigi/binfmt --install all
	@echo "$(GREEN)Buildx构建器设置完成$(NC)"
	@docker buildx inspect

# 列出支持的平台
.PHONY: list-platforms
list-platforms:
	@echo "========================================="
	@echo "支持的平台架构"
	@echo "========================================="
	@echo "  linux/amd64   - Intel/AMD 64位 (x86_64)"
	@echo "  linux/arm64   - ARM 64位 (aarch64)"
	@echo "  linux/arm/v7  - ARM 32位"
	@echo "  linux/riscv64 - RISC-V 64位"
	@echo "========================================="
	@echo "当前配置的目标平台:"
	@echo "  $(TARGET_PLATFORMS)"
	@echo "========================================="

# 构建多架构镜像
.PHONY: build-multiarch
build-multiarch: setup-buildx
	@echo "$(GREEN)=========================================$(NC)"
	@echo "$(GREEN)构建多架构Docker镜像$(NC)"
	@echo "$(GREEN)=========================================$(NC)"
	@echo "目标平台: $(TARGET_PLATFORMS)"
	@echo "输出类型: $(BUILD_OUTPUT_TYPE)"
	@if [ "$(BUILD_OUTPUT_TYPE)" = "registry" ]; then \
		echo "镜像仓库: $(REGISTRY)/$(REPO_NAME)"; \
		docker buildx build \
			--platform $(TARGET_PLATFORMS) \
			--builder $(BUILDER_NAME) \
			--tag $(REGISTRY)/$(REPO_NAME):$(IMAGE_TAG) \
			--push \
			-f docker/Dockerfile \
			.; \
	elif [ "$(BUILD_OUTPUT_TYPE)" = "local" ]; then \
		echo "输出到本地Docker镜像存储"; \
		docker buildx build \
			--platform $(TARGET_PLATFORMS) \
			--builder $(BUILDER_NAME) \
			--tag $(IMAGE_NAME):$(IMAGE_TAG) \
			--load \
			-f docker/Dockerfile \
			.; \
	elif [ "$(BUILD_OUTPUT_TYPE)" = "tar" ]; then \
		echo "输出到tar文件: $(OUTPUT_PATH)"; \
		mkdir -p $(OUTPUT_PATH); \
		docker buildx build \
			--platform $(TARGET_PLATFORMS) \
			--builder $(BUILDER_NAME) \
			--tag $(IMAGE_NAME):$(IMAGE_TAG) \
			--output type=tar,dest=$(OUTPUT_PATH)/$(IMAGE_NAME)-$(IMAGE_TAG).tar \
			-f docker/Dockerfile \
			.; \
	fi
	@echo "$(GREEN)多架构镜像构建完成$(NC)"

# 构建AMD64镜像
.PHONY: build-amd64
build-amd64: setup-buildx
	@echo "$(GREEN)=========================================$(NC)"
	@echo "$(GREEN)构建AMD64架构Docker镜像$(NC)"
	@echo "$(GREEN)=========================================$(NC)"
	@docker buildx build \
		--platform linux/amd64 \
		--builder $(BUILDER_NAME) \
		--tag $(IMAGE_NAME):$(IMAGE_TAG)-amd64 \
		--load \
		-f docker/Dockerfile \
		.
	@echo "$(GREEN)AMD64镜像构建完成$(NC)"

# 构建ARM64镜像
.PHONY: build-arm64
build-arm64: setup-buildx
	@echo "$(GREEN)=========================================$(NC)"
	@echo "$(GREEN)构建ARM64架构Docker镜像$(NC)"
	@echo "$(GREEN)=========================================$(NC)"
	@docker buildx build \
		--platform linux/arm64 \
		--builder $(BUILDER_NAME) \
		--tag $(IMAGE_NAME):$(IMAGE_TAG)-arm64 \
		--load \
		-f docker/Dockerfile \
		.
	@echo "$(GREEN)ARM64镜像构建完成$(NC)"

# 构建所有架构
.PHONY: build-all
build-all: setup-buildx
	@echo "$(GREEN)=========================================$(NC)"
	@echo "$(GREEN)构建所有架构Docker镜像$(NC)"
	@echo "$(GREEN)=========================================$(NC)"
	@docker buildx build \
		--platform linux/amd64,linux/arm64,linux/arm/v7,linux/riscv64 \
		--builder $(BUILDER_NAME) \
		--tag $(IMAGE_NAME):$(IMAGE_TAG) \
		-f docker/Dockerfile \
		.
	@echo "$(GREEN)所有架构镜像构建完成$(NC)"

# 导出镜像为tar
.PHONY: export-tar
export-tar:
	@echo "$(GREEN)=========================================$(NC)"
	@echo "$(GREEN)导出镜像为tar文件$(NC)"
	@echo "$(GREEN)=========================================$(NC)"
	@mkdir -p $(OUTPUT_PATH)
	@docker save $(IMAGE_NAME):$(IMAGE_TAG) -o $(OUTPUT_PATH)/$(IMAGE_NAME)-$(IMAGE_TAG).tar
	@echo "$(GREEN)镜像已导出到: $(OUTPUT_PATH)/$(IMAGE_NAME)-$(IMAGE_TAG).tar$(NC)"

# 导入镜像从tar
.PHONY: import-tar
import-tar:
	@if [ -z "$(TAR_FILE)" ]; then \
		echo "$(RED)错误: 请指定tar文件路径$(NC)"; \
		echo "用法: make import-tar TAR_FILE=path/to/image.tar"; \
		exit 1; \
	fi
	@echo "$(GREEN)=========================================$(NC)"
	@echo "$(GREEN)从tar文件导入镜像$(NC)"
	@echo "$(GREEN)=========================================$(NC)"
	@echo "导入文件: $(TAR_FILE)"
	@docker load -i $(TAR_FILE)
	@echo "$(GREEN)镜像导入完成$(NC)"

# 查看多架构镜像信息
.PHONY: inspect-multiarch
inspect-multiarch:
	@echo "========================================="
	@echo "多架构镜像信息"
	@echo "========================================="
	@docker buildx imagetools inspect $(IMAGE_NAME):$(IMAGE_TAG) || \
		echo "镜像不存在或不是多架构镜像"
	@echo "========================================="

# 推送多架构镜像到仓库
.PHONY: push-multiarch
push-multiarch:
	@echo "$(GREEN)=========================================$(NC)"
	@echo "$(GREEN)推送多架构镜像到仓库$(NC)"
	@echo "$(GREEN)=========================================$(NC)"
	@docker buildx build \
		--platform $(TARGET_PLATFORMS) \
		--builder $(BUILDER_NAME) \
		--tag $(REGISTRY)/$(REPO_NAME):$(IMAGE_TAG) \
		--push \
		-f docker/Dockerfile \
		.
	@echo "$(GREEN)镜像推送完成$(NC)"
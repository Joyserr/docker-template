# ROS Docker 开发环境 - 简化版 Makefile
# 所有命令直接内联，无需额外脚本

# 加载环境变量
include docker/.env
export

# 路径配置
DOCKER_DIR := docker
DOCKERFILE := $(DOCKER_DIR)/Dockerfile

# 颜色定义（用于美化输出）
BLUE := \033[36m
GREEN := \033[32m
YELLOW := \033[33m
NC := \033[0m

.PHONY: help init build run stop exec clean rebuild logs

# 默认显示帮助
.DEFAULT_GOAL := help

help: ## 显示帮助信息
	@echo "$(GREEN)ROS Docker 开发环境$(NC)"
	@echo ""
	@echo "$(BLUE)快速开始:$(NC)"
	@echo "  1. make init     - 初始化环境配置"
	@echo "  2. make build    - 构建 Docker 镜像"
	@echo "  3. make run      - 启动容器"
	@echo ""
	@echo "$(BLUE)可用命令:$(NC)"
	@grep -hE '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | awk 'BEGIN {FS = ":.*?## "}; {printf "  $(BLUE)%-12s$(NC) %s\n", $$1, $$2}'
	@echo ""
	@echo "$(BLUE)当前配置:$(NC)"
	@echo "  镜像: $(IMAGE_NAME):$(IMAGE_TAG)"
	@echo "  容器: $(CONTAINER_NAME)"
	@echo "  ROS:  $(ROS_DISTRO)"
	@echo "  用户: $(USER_NAME) (UID=$(USER_UID), GID=$(USER_GID))"

init: ## 初始化环境配置（自动检测系统信息）
	@echo "$(GREEN)==> 初始化环境配置$(NC)"
	@ENV_FILE="$(DOCKER_DIR)/.env"; \
	if [ -f "$$ENV_FILE" ]; then \
		echo "配置已存在，更新用户信息..."; \
	else \
		echo "# user configuration" > "$$ENV_FILE"; \
		echo "# Docker image configuration" >> "$$ENV_FILE"; \
		echo "IMAGE_NAME=ros-dev" >> "$$ENV_FILE"; \
		echo "IMAGE_TAG=latest" >> "$$ENV_FILE"; \
		echo "CONTAINER_NAME=ros_dev_container" >> "$$ENV_FILE"; \
		echo "" >> "$$ENV_FILE"; \
		echo "# ROS distribution" >> "$$ENV_FILE"; \
		echo "ROS_DISTRO=noetic" >> "$$ENV_FILE"; \
		echo "" >> "$$ENV_FILE"; \
		echo "# mount workspace" >> "$$ENV_FILE"; \
	fi; \
	sed -i.bak "s/^USER_NAME=.*/USER_NAME=$$(whoami)/" "$$ENV_FILE" && rm -f "$$ENV_FILE.bak"; \
	sed -i.bak "s/^USER_UID=.*/USER_UID=$$(id -u)/" "$$ENV_FILE" && rm -f "$$ENV_FILE.bak"; \
	sed -i.bak "s/^USER_GID=.*/USER_GID=$$(id -g)/" "$$ENV_FILE" && rm -f "$$ENV_FILE.bak"; \
	sed -i.bak "s|^WORKSPACE_DIR=.*|WORKSPACE_DIR=$$(pwd)|" "$$ENV_FILE" && rm -f "$$ENV_FILE.bak"; \
	echo "$(GREEN)==> 配置完成$(NC)"

build: ## 构建 Docker 镜像
	@echo "$(GREEN)==> 构建镜像: $(IMAGE_NAME):$(IMAGE_TAG)$(NC)"
	@docker build \
		--build-arg ROS_DISTRO=$(ROS_DISTRO) \
		--build-arg USER_NAME=$(USER_NAME) \
		--build-arg USER_UID=$(USER_UID) \
		--build-arg USER_GID=$(USER_GID) \
		-f $(DOCKERFILE) \
		-t $(IMAGE_NAME):$(IMAGE_TAG) \
		$(DOCKER_DIR)
	@echo "$(GREEN)==> 构建完成！$(NC)"

run: ## 运行容器（交互式）
	@echo "$(GREEN)==> 启动容器: $(CONTAINER_NAME)$(NC)"
	@xhost +local:docker 2>/dev/null || true
	@docker run -it --rm \
		--name $(CONTAINER_NAME) \
		--network host \
		--privileged \
		-v $(WORKSPACE_DIR):/home/$(USER_NAME)/catkin_ws \
		-v $(PWD)/docker/config/bashrc:/home/$(USER_NAME)/.bashrc_docker:ro \
		-v /tmp/.X11-unix:/tmp/.X11-unix \
		-e DISPLAY=$(DISPLAY) \
		-e QT_X11_NO_MITSHM=1 \
		$(IMAGE_NAME):$(IMAGE_TAG)

run-d: ## 后台运行容器
	@echo "$(GREEN)==> 后台启动容器: $(CONTAINER_NAME)$(NC)"
	@xhost +local:docker 2>/dev/null || true
	@docker run -d \
		--name $(CONTAINER_NAME) \
		--network host \
		--privileged \
		-v $(WORKSPACE_DIR):/home/$(USER_NAME)/catkin_ws \
		-v $(PWD)/docker/config/bashrc:/home/$(USER_NAME)/.bashrc_docker:ro \
		-v /tmp/.X11-unix:/tmp/.X11-unix \
		-e DISPLAY=$(DISPLAY) \
		-e QT_X11_NO_MITSHM=1 \
		$(IMAGE_NAME):$(IMAGE_TAG) \
		tail -f /dev/null
	@echo "$(GREEN)==> 容器已在后台运行$(NC)"
	@echo "    make exec  - 进入容器"
	@echo "    make stop  - 停止容器"

exec: ## 进入运行中的容器
	@echo "$(GREEN)==> 进入容器$(NC)"
	@docker exec -it $(CONTAINER_NAME) /bin/bash || \
		(echo "$(YELLOW)错误: 容器未运行，请先执行 'make run-d'$(NC)" && exit 1)

stop: ## 停止并删除容器
	@echo "$(GREEN)==> 停止容器$(NC)"
	@docker stop $(CONTAINER_NAME) 2>/dev/null || true
	@docker rm $(CONTAINER_NAME) 2>/dev/null || true
	@echo "$(GREEN)==> 容器已停止$(NC)"

clean: ## 清理容器和镜像
	@echo "$(GREEN)==> 清理容器和镜像$(NC)"
	@docker stop $(CONTAINER_NAME) 2>/dev/null || true
	@docker rm $(CONTAINER_NAME) 2>/dev/null || true
	@docker rmi $(IMAGE_NAME):$(IMAGE_TAG) 2>/dev/null || true
	@echo "$(GREEN)==> 清理完成$(NC)"

rebuild: ## 重新构建（清理后构建）
rebuild: clean build

logs: ## 查看容器日志
	@docker logs -f $(CONTAINER_NAME) 2>/dev/null || \
		echo "$(YELLOW)容器未运行$(NC)"

status: ## 查看容器状态
	@echo "$(BLUE)容器状态:$(NC)"
	@docker ps -a --filter "name=$(CONTAINER_NAME)" --format "table {{.Names}}\t{{.Status}}\t{{.Ports}}" 2>/dev/null || true
	@echo ""
	@echo "$(BLUE)镜像列表:$(NC)"
	@docker images $(IMAGE_NAME) --format "table {{.Repository}}\t{{.Tag}}\t{{.Size}}\t{{.CreatedAt}}" 2>/dev/null || true

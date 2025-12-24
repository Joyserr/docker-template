# 加载环境变量（从docker目录）
include docker/.env
export

# Docker相关文件路径
DOCKER_DIR := docker
DOCKERFILE := $(DOCKER_DIR)/Dockerfile
COMPOSE_FILE := $(DOCKER_DIR)/docker-compose.yml

.PHONY: help init build run run-detach exec stop clean rebuild logs shell status ps

# 默认目标
.DEFAULT_GOAL := help

help: ## 显示帮助信息
	@echo "ROS Noetic Docker 开发环境"
	@echo ""
	@echo "可用命令："
	@grep -hE '^[a-zA-Z_-]+:.*?## .*$$' Makefile | sort | awk 'BEGIN {FS = ":.*?## "}; {printf "  \033[36m%-15s\033[0m %s\n", $$1, $$2}'
	@echo ""
	@echo "环境配置："
	@echo "  镜像名称: $(IMAGE_NAME):$(IMAGE_TAG)"
	@echo "  容器名称: $(CONTAINER_NAME)"
	@echo "  ROS版本:  $(ROS_DISTRO)"
	@echo "  用户信息: $(USER_NAME) (UID=$(USER_UID), GID=$(USER_GID))"

init: ## 初始化环境配置（自动检测系统信息）
	@./docker/scripts/init-env.sh

build: ## 构建Docker镜像
	@echo "==> 构建Docker镜像: $(IMAGE_NAME):$(IMAGE_TAG)"
	@echo "    ROS版本: $(ROS_DISTRO)"
	@echo "    用户: $(USER_NAME) (UID=$(USER_UID), GID=$(USER_GID))"
	docker build \
		--build-arg ROS_DISTRO=$(ROS_DISTRO) \
		--build-arg USER_NAME=$(USER_NAME) \
		--build-arg USER_UID=$(USER_UID) \
		--build-arg USER_GID=$(USER_GID) \
		-f $(DOCKERFILE) \
		-t $(IMAGE_NAME):$(IMAGE_TAG) \
		$(DOCKER_DIR)
	@echo "==> 构建完成！"

run: ## 运行容器（交互式，退出后自动删除）
	@echo "==> 启动容器: $(CONTAINER_NAME)"
	@xhost +local:docker > /dev/null 2>&1 || true
	docker run -it --rm \
		--name $(CONTAINER_NAME) \
		--network host \
		--privileged \
		-v $(WORKSPACE_DIR):/home/$(USER_NAME)/catkin_ws \
		-v ${WORKSPACE_DIR}/docker/config/bashrc:/home/${USER_NAME}/.bashrc_docker:ro \
		-v /tmp/.X11-unix:/tmp/.X11-unix \
		-e DISPLAY=$(DISPLAY) \
		-e QT_X11_NO_MITSHM=1 \
		$(IMAGE_NAME):$(IMAGE_TAG)

run-detach: ## 后台运行容器
	@echo "==> 后台启动容器: $(CONTAINER_NAME)"
	@xhost +local:docker > /dev/null 2>&1 || true
	docker run -d \
		--name $(CONTAINER_NAME) \
		--network host \
		--privileged \
		-v $(WORKSPACE_DIR):/home/$(USER_NAME)/catkin_ws \
		-v ${WORKSPACE_DIR}/docker/config/bashrc:/home/${USER_NAME}/.bashrc_docker:ro \
		-v /tmp/.X11-unix:/tmp/.X11-unix \
		-e DISPLAY=$(DISPLAY) \
		-e QT_X11_NO_MITSHM=1 \
		$(IMAGE_NAME):$(IMAGE_TAG) \
		tail -f /dev/null
	@echo "==> 容器已在后台运行"
	@echo "    使用 'make exec' 进入容器"
	@echo "    使用 'make logs' 查看日志"
	@echo "    使用 'make stop' 停止容器"

exec: ## 进入运行中的容器
	@echo "==> 进入容器: $(CONTAINER_NAME)"
	@docker exec -it $(CONTAINER_NAME) /bin/bash || \
		(echo "错误: 容器未运行，请先执行 'make run-detach'" && exit 1)

stop: ## 停止并删除容器
	@echo "==> 停止容器: $(CONTAINER_NAME)"
	@docker stop $(CONTAINER_NAME) 2>/dev/null || true
	@docker rm $(CONTAINER_NAME) 2>/dev/null || true
	@echo "==> 容器已停止"

clean: ## 清理容器和镜像
	@echo "==> 清理容器和镜像"
	@docker stop $(CONTAINER_NAME) 2>/dev/null || true
	@docker rm $(CONTAINER_NAME) 2>/dev/null || true
	@docker rmi $(IMAGE_NAME):$(IMAGE_TAG) 2>/dev/null || true
	@echo "==> 清理完成"

rebuild: ## 清理并重新构建镜像
rebuild: clean build

logs: ## 查看容器日志
	@docker logs -f $(CONTAINER_NAME)

shell: ## 运行容器并进入shell（run的别名）
shell: run

status: ## 查看容器状态
	@echo "==> 容器状态:"
	@docker ps -a --filter "name=$(CONTAINER_NAME)" --format "table {{.Names}}\t{{.Status}}\t{{.Image}}" || echo "无相关容器"

ps: ## 查看容器状态（status的别名）
ps: status

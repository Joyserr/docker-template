# Docker 开发环境模板

一套通用的 Docker 容器化开发环境，支持 ROS1/ROS2、Python、Node.js、Java、Go、Ubuntu 等 12 种模板。
通过 `make` 命令统一管理构建和运行，零脚本直接上手。

## 快速开始

```bash
# 1. 初始化配置（自动检测用户信息）
make init

# 2. 选择开发环境模板
make use T=ros2-humble

# 3. 构建并启动
make up

# 4. 进入容器
make shell
```

**一键完成 2-4 步：**

```bash
make setup T=ros2-humble
```

## 可用模板

| 模板名 | 说明 |
|---|---|
| `ros1-noetic` | ROS1 Noetic (Ubuntu 20.04) |
| `ros2-humble` | ROS2 Humble (Ubuntu 22.04) |
| `ros2-foxy` | ROS2 Foxy (Ubuntu 20.04) |
| `ros2-jazzy` | ROS2 Jazzy (Ubuntu 24.04) |
| `python-3.11` | Python 3.11 |
| `python-3.12` | Python 3.12 |
| `nodejs-18` | Node.js 18 |
| `nodejs-20` | Node.js 20 |
| `java-11` | Java 11 |
| `java-17` | Java 17 |
| `go-22` | Go 1.22 |
| `ubuntu` | Ubuntu 22.04 通用环境 |

## 日常命令

```bash
make build       # 构建镜像
make up          # 后台启动容器
make run         # 交互式启动（直接进入 bash）
make shell       # 进入已运行的容器
make down        # 停止并删除容器
make restart     # 重启容器
make logs        # 查看容器日志
make ps          # 查看容器状态
make exec CMD='ls'  # 在容器内执行命令
make rebuild     # 无缓存重新构建
make clean       # 清理容器和镜像
make config      # 查看当前配置
```

## 项目结构

```
Makefile                  # 入口：所有操作通过 make 执行
docker/
  docker-compose.yml      # 唯一运行配置（构建 + 运行统一）
  Dockerfile              # 当前使用的 Dockerfile（由模板复制）
  requirements.txt        # Python 依赖
  config/
    .env                  # 环境变量（make init 生成）
    .env.example          # 配置示例
    bashrc                # 容器 shell 配置
  templates/              # 模板库（不直接修改）
    ros1/ ros2/ python/ nodejs/ java/ go/ ubuntu/
```

## 工作流程

```
make init → 生成 .env（用户信息、镜像名、工作空间路径）
    ↓
make use T=xxx → 从 templates/ 复制 Dockerfile + bashrc + 依赖文件
    ↓
make build → docker compose build（读取 .env + Dockerfile）
    ↓
make up → docker compose up -d（后台启动）
make shell → docker compose exec dev bash（进入容器）
```

所有操作统一走 `docker compose`，不再有 `docker run` 与 `docker-compose` 两条路径。

## 配置说明

`docker/config/.env` 中的关键配置：

```bash
USER_NAME=yourname     # 容器内用户名（与主机一致）
USER_UID=1000          # 用户 UID
USER_GID=1000          # 用户 GID
IMAGE_NAME=dev         # 镜像名
IMAGE_TAG=latest       # 镜像标签
CONTAINER_NAME=dev     # 容器名
WORKSPACE_DIR=/path    # 挂载到容器的工作空间路径
CONTAINER_WORKSPACE=workspace  # 容器内工作目录名
```

## 自定义

- **修改依赖**：编辑 `docker/requirements.txt`（Python）或对应的 `package.json` / `pom.xml`
- **修改容器环境**：编辑 `docker/config/bashrc`
- **修改基础镜像**：直接编辑 `docker/Dockerfile`
- **切换模板**：`make use T=<新模板>` 然后 `make rebuild`

## GUI 支持

容器默认支持 X11 图形界面转发（Linux），可直接运行 RViz、Gazebo 等 GUI 工具。
启动前需确保主机已允许 X11 访问（`make up` 会自动执行 `xhost +local:docker`）。

## License

MIT

# 🚀 快速开始指南

## 🎯 新手请从这里开始

### 一步到位配置（强烈推荐）
```bash
make setup
```
这将启动交互式配置向导，引导您：
1. 选择开发环境类型（ROS/Python/Node.js等）
2. 自动配置环境变量
3. 应用相应模板
4. 构建并启动容器

### 传统方式配置

1. **初始化环境**
   ```bash
   make init
   ```

2. **选择开发模板**
   ```bash
   # 交互式选择
   make template-select
   
   # 或直接指定模板
   make template-use TEMPLATE=ros2-humble
   ```

3. **构建镜像**
   ```bash
   make build
   ```

4. **启动开发环境**
   ```bash
   make run
   ```

## ⚡ 日常使用命令

```bash
# 停止容器
make stop

# 重新构建（修改Dockerfile后）
make rebuild

# 查看容器状态
make ps

# 进入运行中的容器
make enter

# 查看当前配置
make config
```

## 🎨 支持的开发环境

- **ROS机器人开发**：ROS1 Noetic, ROS2 Humble/Foxy/Jazzy
- **编程语言**：Python 3.11/3.12, Node.js 18/20, Java 11/17, Go 1.22
- **系统环境**：Ubuntu 22.04 通用开发环境

## 📚 详细帮助

```bash
# 查看所有可用命令
make help

# 查看快速开始指南
make quick-start

# 列出所有模板
make template-list
```

---
*更多详细信息请查看完整的 README.md*
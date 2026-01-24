# Ubuntu 22.04 通用开发环境模板
FROM ubuntu:22.04

# 避免交互式提示
ENV DEBIAN_FRONTEND=noninteractive

# 设置时区为中国时区
RUN ln -sf /usr/share/zoneinfo/Asia/Shanghai /etc/localtime && \
    echo "Asia/Shanghai" > /etc/timezone

# 配置国内镜像源
RUN sed -i 's|http://archive.ubuntu.com/ubuntu|https://mirrors.ustc.edu.cn/ubuntu|g' /etc/apt/sources.list && \
    sed -i 's|http://security.ubuntu.com/ubuntu|https://mirrors.ustc.edu.cn/ubuntu|g' /etc/apt/sources.list

# 更新apt源并安装基础开发工具
RUN apt-get update && apt-get install -y \
    vim \
    wget \
    htop \
    tmux \
    build-essential \
    cmake \
    git \
    curl \
    bash-completion \
    sudo \
    unzip \
    software-properties-common \
    apt-transport-https \
    ca-certificates \
    gnupg \
    lsb-release \
    && rm -rf /var/lib/apt/lists/*

# 安装编程语言环境
RUN apt-get update && apt-get install -y \
    python3 \
    python3-pip \
    python3-venv \
    python3-dev \
    nodejs \
    npm \
    golang-go \
    openjdk-11-jdk \
    && rm -rf /var/lib/apt/lists/*

# 安装额外的开发工具
RUN apt-get update && apt-get install -y \
    docker.io \
    docker-compose \
    kubectl \
    helm \
    terraform \
    ansible \
    postgresql-client \
    mysql-client \
    redis-tools \
    nmap \
    net-tools \
    iputils-ping \
    traceroute \
    && rm -rf /var/lib/apt/lists/*

# 安装Shell工具
RUN apt-get update && apt-get install -y \
    zsh \
    fish \
    tree \
    less \
    jq \
    yq \
    fzf \
    ripgrep \
    bat \
    exa \
    && rm -rf /var/lib/apt/lists/*

# 升级npm并安装全局工具
RUN npm install -g \
    yarn \
    pnpm \
    typescript \
    nodemon \
    @nestjs/cli \
    create-react-app \
    @vue/cli

# 升级pip并安装基础Python包
RUN pip3 install --upgrade pip setuptools wheel && \
    pip3 install --no-cache-dir \
    ipython \
    jupyter \
    pytest \
    black \
    flake8

# 设置Go环境
ENV GOPATH=$HOME/go
ENV GOBIN=$GOPATH/bin
ENV PATH=$GOBIN:$PATH

# 安装Go工具
RUN go install -a golang.org/x/tools/cmd/goimports@latest

# 创建用户（与主机用户保持一致，避免权限问题）
ARG USER_NAME=sysadmin
ARG USER_UID=1000
ARG USER_GID=1000

RUN groupadd -g ${USER_GID} ${USER_NAME} || true && \
    useradd -m -u ${USER_UID} -g ${USER_GID} -s /bin/bash ${USER_NAME} && \
    echo "${USER_NAME} ALL=(ALL) NOPASSWD:ALL" >> /etc/sudoers

# 切换到用户
USER ${USER_NAME}
WORKDIR /home/${USER_NAME}

# 设置工作空间
RUN mkdir -p ~/workspace
RUN mkdir -p ~/go/src ~/go/bin
WORKDIR /home/${USER_NAME}/workspace

# 复制自定义 bashrc 配置
COPY --chown=${USER_NAME}:${USER_NAME} docker/templates/ubuntu/bashrc /home/${USER_NAME}/.bashrc_docker

# 配置开发环境（加载 Docker 专用配置）
RUN echo "# Load Docker-specific development configuration" >> ~/.bashrc && \
    echo "if [ -f ~/.bashrc_docker ]; then" >> ~/.bashrc && \
    echo "    source ~/.bashrc_docker" >> ~/.bashrc && \
    echo "fi" >> ~/.bashrc

# 默认启动bash
CMD ["/bin/bash"]
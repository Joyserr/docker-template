# Ubuntu 22.04 General Development Environment
FROM ubuntu:22.04

ARG USE_CN_MIRROR=true
ENV DEBIAN_FRONTEND=noninteractive

RUN ln -sf /usr/share/zoneinfo/Asia/Shanghai /etc/localtime && \
    echo "Asia/Shanghai" > /etc/timezone

# Configure apt mirror (optional)
RUN if [ "$USE_CN_MIRROR" = "true" ]; then \
        sed -i 's|http://archive.ubuntu.com/ubuntu|https://mirrors.ustc.edu.cn/ubuntu|g' /etc/apt/sources.list && \
        sed -i 's|http://security.ubuntu.com/ubuntu|https://mirrors.ustc.edu.cn/ubuntu|g' /etc/apt/sources.list && \
        sed -i 's|http://ports.ubuntu.com/ubuntu-ports|https://mirrors.ustc.edu.cn/ubuntu-ports|g' /etc/apt/sources.list; \
    fi

# Install system packages
RUN apt-get update && apt-get install -y \
    vim wget htop tmux \
    build-essential cmake git curl \
    bash-completion sudo unzip \
    software-properties-common apt-transport-https \
    ca-certificates gnupg lsb-release \
    && rm -rf /var/lib/apt/lists/*

# Install programming language runtimes
RUN apt-get update && apt-get install -y \
    python3 python3-pip python3-venv python3-dev \
    nodejs npm \
    golang-go \
    openjdk-11-jdk \
    && rm -rf /var/lib/apt/lists/*

# Install development tools
RUN apt-get update && apt-get install -y \
    postgresql-client \
    mysql-client \
    redis-tools \
    net-tools iputils-ping traceroute nmap \
    && rm -rf /var/lib/apt/lists/*

# Install shell utilities
RUN apt-get update && apt-get install -y \
    zsh fish \
    tree less jq fzf ripgrep \
    && rm -rf /var/lib/apt/lists/*

# Install global npm tools
RUN npm install -g yarn pnpm typescript nodemon \
    @nestjs/cli create-react-app @vue/cli

# Install base Python packages
RUN pip3 install --no-cache-dir --upgrade pip setuptools wheel && \
    pip3 install --no-cache-dir ipython jupyter pytest black flake8

# Set up Go environment
ENV GOPATH=/root/go
ENV GOBIN=$GOPATH/bin
ENV PATH=$GOBIN:$PATH

# Create user (match host UID/GID to avoid permission issues)
ARG USER_NAME=sysadmin
ARG USER_UID=1000
ARG USER_GID=1000

RUN groupadd -g ${USER_GID} ${USER_NAME} || true && \
    useradd -m -u ${USER_UID} -g ${USER_GID} -s /bin/bash ${USER_NAME} && \
    echo "${USER_NAME} ALL=(ALL) NOPASSWD:ALL" >> /etc/sudoers

USER ${USER_NAME}
WORKDIR /home/${USER_NAME}

RUN mkdir -p ~/workspace ~/go/src ~/go/bin
WORKDIR /home/${USER_NAME}/workspace

# Copy custom bashrc configuration
COPY --chown=${USER_NAME}:${USER_NAME} docker/config/bashrc /home/${USER_NAME}/.bashrc_docker
RUN echo "if [ -f ~/.bashrc_docker ]; then source ~/.bashrc_docker; fi" >> ~/.bashrc

CMD ["/bin/bash"]

ARG AIRFLOW_IMAGE=apache/airflow:3.2.1-python3.12
FROM ${AIRFLOW_IMAGE}

ARG USE_CN_MIRROR=true
ARG TZ=Asia/Shanghai
ENV DEBIAN_FRONTEND=noninteractive
ENV PATH="/home/airflow/.local/bin:${PATH}"

USER root

RUN ln -sf /usr/share/zoneinfo/${TZ} /etc/localtime && \
    echo "${TZ}" > /etc/timezone

RUN if [ "$USE_CN_MIRROR" = "true" ] && [ -f /etc/apt/sources.list ]; then \
        sed -i 's|http://deb.debian.org/debian|https://mirrors.ustc.edu.cn/debian|g' /etc/apt/sources.list && \
        sed -i 's|http://security.debian.org|https://mirrors.ustc.edu.cn/debian-security|g' /etc/apt/sources.list; \
    fi

RUN apt-get update && apt-get install -y --no-install-recommends \
        bash-completion sudo \
        build-essential cmake ninja-build pkg-config \
        git curl wget vim \
        ca-certificates gnupg \
        libpq-dev default-libmysqlclient-dev \
        libffi-dev libssl-dev zlib1g-dev \
    && rm -rf /var/lib/apt/lists/*

RUN chmod o+rx /home/airflow && \
    if [ -d /home/airflow/.local ]; then chmod -R o+rX /home/airflow/.local; fi && \
    ln -sf /home/airflow/.local/bin/airflow /usr/local/bin/airflow && \
    ln -sf /home/airflow/.local/bin/apache-airflow /usr/local/bin/apache-airflow

RUN PY_VER="$(python3 -c 'import sys; print("{}.{}".format(sys.version_info.major, sys.version_info.minor))')" && \
    printf '%s\n' \
      "export PYTHONPATH=/home/airflow/.local/lib/python${PY_VER}/site-packages:\${PYTHONPATH}" \
      > /etc/profile.d/airflow-pythonpath.sh && \
    printf '%s\n' \
      '[ -f /etc/profile.d/airflow-pythonpath.sh ] && . /etc/profile.d/airflow-pythonpath.sh' \
      >> /etc/bash.bashrc

ARG USER_NAME=sysadmin
ARG USER_UID=1000
ARG USER_GID=1000

RUN groupadd -g ${USER_GID} ${USER_NAME} || true && \
    useradd -m -u ${USER_UID} -g ${USER_GID} -s /bin/bash ${USER_NAME} && \
    echo "${USER_NAME} ALL=(ALL) NOPASSWD:ALL" >> /etc/sudoers

USER ${USER_NAME}
WORKDIR /home/${USER_NAME}

COPY --chown=${USER_NAME}:${USER_NAME} docker/requirements.txt /tmp/requirements.txt
RUN python3 -m pip install --user --no-cache-dir -r /tmp/requirements.txt || true && \
    rm /tmp/requirements.txt

RUN mkdir -p ~/workspace
WORKDIR /home/${USER_NAME}/workspace

COPY --chown=${USER_NAME}:${USER_NAME} docker/config/bashrc /home/${USER_NAME}/.bashrc_docker
RUN echo "if [ -f ~/.bashrc_docker ]; then source ~/.bashrc_docker; fi" >> ~/.bashrc

HEALTHCHECK --interval=30s --timeout=10s --start-period=5s --retries=3 \
    CMD pgrep -x "bash" > /dev/null || exit 1

ENTRYPOINT []
CMD ["/bin/bash"]

FROM ghcr.io/akash-network/ubuntu-2404-ssh:2

# 设置环境变量
ENV DEBIAN_FRONTEND=noninteractive \
    TZ=Asia/Bangkok

# 安装基础工具和依赖
RUN apt-get update && \
    apt-get install -y \
        vim \
        cron \
        tzdata \
        git \
        curl \
        ca-certificates && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

# 配置时区
RUN ln -snf /usr/share/zoneinfo/$TZ /etc/localtime && echo $TZ > /etc/timezone

# 安装 UV (Python 包管理工具) 并验证
RUN curl -LsSf https://astral.sh/uv/install.sh | sh && \
    /root/.local/bin/uv --version

# 添加 UV 到 PATH (后续层可以直接使用 uv 命令)
ENV PATH="/root/.local/bin:${PATH}"

# 创建增强的 init.sh 脚本
RUN mv /usr/local/bin/init.sh /usr/local/bin/init.sh.original

COPY init.sh /usr/local/bin/init.sh
RUN chmod +x /usr/local/bin/init.sh

# 继承基础镜像的配置
# ENTRYPOINT ["/tini", "--", "/usr/local/bin/init.sh"]
# CMD ["tail", "-f", "/dev/null"]

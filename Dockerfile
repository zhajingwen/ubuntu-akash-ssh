FROM ghcr.io/akash-network/ubuntu-2404-ssh:2

# 构建参数
ARG LARKBOT_ID="e15eaffe-05db-48f2-8059-a78b1beff8c9"
ARG REPO_URL="https://github.com/zhajingwen/hyperliquid-pair-coins-realtime-analyze.git"

# 元数据标签
LABEL maintainer="your-email@example.com" \
      description="Ubuntu SSH with uv and hyperliquid-pair-coins-realtime-analyze" \
      version="1.0.0"

# 设置环境变量
ENV DEBIAN_FRONTEND=noninteractive \
    TZ=Asia/Bangkok \
    PATH="/root/.local/bin:${PATH}" \
    LARKBOT_ID="${LARKBOT_ID}" \
    LANG=C.UTF-8 \
    LC_ALL=C.UTF-8 \
    PYTHONUNBUFFERED=1

# 【优化1】合并所有系统包安装和工具安装为一层（减少层数）
# 【优化2】使用 --depth 1 浅克隆（减少下载大小）
# 【优化3】保留 .git 目录（支持后续使用 git 命令）
# 【优化4】清理所有缓存和临时文件（减少镜像大小）
RUN apt-get update && \
    apt-get install -y --no-install-recommends \
        vim-tiny \
        tzdata \
        git \
        curl \
        ca-certificates \
        locales && \
    locale-gen en_US.UTF-8 zh_CN.UTF-8 && \
    update-locale LANG=C.UTF-8 LC_ALL=C.UTF-8 && \
    ln -snf /usr/share/zoneinfo/$TZ /etc/localtime && \
    echo $TZ > /etc/timezone && \
    curl -LsSf https://astral.sh/uv/install.sh | sh && \
    /root/.local/bin/uv --version && \
    echo 'export PATH="/root/.local/bin:$PATH"' >> /root/.bashrc && \
    echo 'export PATH="/root/.local/bin:$PATH"' >> /root/.profile && \
    cd /root && \
    git clone --depth 1 ${REPO_URL} && \
    cd hyperliquid-pair-coins-realtime-analyze && \
    /root/.local/bin/uv sync && \
    mkdir -p logs && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/* /root/.cache

WORKDIR /root/hyperliquid-pair-coins-realtime-analyze

# 【优化5】合并 COPY 和 chmod（减少1层）
RUN mv /usr/local/bin/init.sh /usr/local/bin/init.sh.original
COPY --chmod=755 init.sh /usr/local/bin/init.sh

# 复制监控脚本
COPY --chmod=755 app_monitor.py /root/app_monitor.py

# 【优化6】添加健康检查
HEALTHCHECK --interval=30s --timeout=3s --start-period=5s --retries=3 \
    CMD service ssh status || exit 1

# 继承基础镜像的配置，并运行应用
ENTRYPOINT ["/tini", "--", "/usr/local/bin/init.sh"]
# CMD ["/bin/bash", "-c", "cd /root/hyperliquid-pair-coins-realtime-analyze && uv run python -m src.services.realtime_kline_service_hype"]
CMD ["uv", "run", "python", "/root/app_monitor.py", "-i", "3600"]

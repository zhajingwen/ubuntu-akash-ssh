FROM ghcr.io/akash-network/ubuntu-2404-ssh:2

# 构建参数
ARG LARKBOT_ID="e15eaffe-05db-48f2-8059-a78b1beff8c9"
ARG REPO_URL="https://github.com/zhajingwen/hyperliquid-btc-lag-tracker-.git"
ARG CRON_SCHEDULE="0 */2 * * *"

# 元数据标签
LABEL maintainer="your-email@example.com" \
      description="Ubuntu SSH with cron, uv, and hyperliquid-btc-lag-tracker" \
      version="1.0.0"

# 设置环境变量
ENV DEBIAN_FRONTEND=noninteractive \
    TZ=Asia/Bangkok \
    PATH="/root/.local/bin:${PATH}" \
    LARKBOT_ID="${LARKBOT_ID}" \
    LANG=C.UTF-8 \
    LC_ALL=C.UTF-8

# 【优化1】合并所有系统包安装和工具安装为一层（减少层数）
# 【优化2】使用 --depth 1 浅克隆（减少下载大小）
# 【优化3】删除 .git 目录（减少镜像大小 10-20MB）
# 【优化4】清理所有缓存和临时文件（减少镜像大小）
RUN apt-get update && \
    apt-get install -y --no-install-recommends \
        vim-tiny \
        cron \
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
    cd /root && \
    git clone --depth 1 ${REPO_URL} && \
    cd hyperliquid-btc-lag-tracker- && \
    /root/.local/bin/uv sync && \
    rm -rf .git && \
    mkdir -p /etc/cron.d && \
    echo "LARKBOT_ID=\${LARKBOT_ID}" > /root/crontab.txt && \
    echo "${CRON_SCHEDULE} cd /root/hyperliquid-btc-lag-tracker- && /root/.local/bin/uv run hyperliquid_analyzer.py >> /root/hyperliquid-btc-lag-tracker-/hyperliquid.log 2>&1" >> /root/crontab.txt && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/* /root/.cache

WORKDIR /root/hyperliquid-btc-lag-tracker-

# 【优化5】合并 COPY 和 chmod（减少1层）
RUN mv /usr/local/bin/init.sh /usr/local/bin/init.sh.original
COPY --chmod=755 init.sh /usr/local/bin/init.sh

# 【优化6】添加健康检查
HEALTHCHECK --interval=30s --timeout=3s --start-period=5s --retries=3 \
    CMD service cron status && service ssh status || exit 1

# 继承基础镜像的配置
# ENTRYPOINT ["/tini", "--", "/usr/local/bin/init.sh"]
# CMD ["tail", "-f", "/dev/null"]

FROM ghcr.io/akash-network/ubuntu-2404-ssh:2

# 设置环境变量
ENV DEBIAN_FRONTEND=noninteractive \
    TZ=Asia/Bangkok

# 安装 vim 和 cron
RUN apt-get update && \
    apt-get install -y \
        vim \
        cron \
        tzdata && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

# 配置时区
RUN ln -snf /usr/share/zoneinfo/$TZ /etc/localtime && echo $TZ > /etc/timezone

# 创建增强的 init.sh 脚本
RUN mv /usr/local/bin/init.sh /usr/local/bin/init.sh.original

COPY init.sh /usr/local/bin/init.sh
RUN chmod +x /usr/local/bin/init.sh

# 继承基础镜像的配置
# ENTRYPOINT ["/tini", "--", "/usr/local/bin/init.sh"]
# CMD ["tail", "-f", "/dev/null"]

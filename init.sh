#!/bin/bash
set -e

echo "$(date): Starting initialization..."

# 原始功能: 设置 SSH 公钥
if [ -z "$SSH_PUBKEY" ]; then
  echo "$(date): Warning: SSH_PUBKEY is not set"
else
  mkdir -p ~/.ssh
  chmod 700 ~/.ssh
  echo "$SSH_PUBKEY" > ~/.ssh/authorized_keys
  chmod 600 ~/.ssh/authorized_keys
  pubkey_preview="${SSH_PUBKEY:0:20}***"
  echo "$(date): SSH_PUBKEY (${pubkey_preview}) written to ~/.ssh/authorized_keys"
fi

# 加载 crontab 配置并替换环境变量
if [ -f /root/crontab.txt ]; then
  echo "$(date): Loading crontab configuration..."

  # 创建临时文件并替换环境变量
  TEMP_CRONTAB=$(mktemp)

  # 替换 LARKBOT_ID 环境变量（使用实际值）
  sed "s|\${LARKBOT_ID}|${LARKBOT_ID}|g" /root/crontab.txt > "$TEMP_CRONTAB"

  # 加载处理后的 crontab
  crontab "$TEMP_CRONTAB"
  rm -f "$TEMP_CRONTAB"

  echo "$(date): Crontab loaded successfully with LARKBOT_ID=${LARKBOT_ID}"
fi

# 启动 cron 服务
echo "$(date): Starting cron service..."
service cron start

# 检查 cron 服务状态
if service cron status > /dev/null 2>&1; then
  echo "$(date): Cron service started successfully"
  # 显示当前 crontab 配置
  echo "$(date): Current crontab entries:"
  crontab -l 2>/dev/null || echo "  (no crontab entries)"
else
  echo "$(date): Warning: Cron service may not have started properly"
fi

# 原始功能: 启动 SSH 服务
echo "$(date): Starting SSH service..."
/usr/sbin/sshd

echo "$(date): Initialization complete. SSH and Cron services are running."

# 执行传入的命令(默认是 tail -f /dev/null)
exec "$@"

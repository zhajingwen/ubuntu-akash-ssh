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

# 启动 cron 服务
echo "$(date): Starting cron service..."
service cron start

# 检查 cron 服务状态
if service cron status > /dev/null 2>&1; then
  echo "$(date): Cron service started successfully"
else
  echo "$(date): Warning: Cron service may not have started properly"
fi

# 原始功能: 启动 SSH 服务
echo "$(date): Starting SSH service..."
/usr/sbin/sshd

echo "$(date): Initialization complete. SSH and Cron services are running."

# 执行传入的命令(默认是 tail -f /dev/null)
exec "$@"

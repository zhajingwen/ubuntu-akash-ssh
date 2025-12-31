# 本地构建测试指南

## 快速开始

### 1. 标准测试
```bash
./test-build.sh
```

### 2. 清理旧镜像后测试
```bash
./test-build.sh --clean
```

### 3. 使用自定义端口
```bash
./test-build.sh --port 3333
```

### 4. 自定义构建参数
```bash
./test-build.sh --build-arg CRON_SCHEDULE="0 */1 * * *" --build-arg LARKBOT_ID="your-bot-id"
```

### 5. 仅测试现有镜像(跳过构建)
```bash
./test-build.sh --no-build
```

## 脚本功能

测试脚本会自动执行以下操作：

### 阶段 1: 清理环境
- ✅ 停止并删除旧的测试容器
- ✅ 可选删除旧的测试镜像 (`--clean` 参数)

### 阶段 2: 构建镜像
- ✅ 使用 Dockerfile 构建镜像
- ✅ 支持自定义构建参数
- ✅ 显示构建进度和结果

### 阶段 3: 验证镜像
- ✅ 显示镜像信息 (ID, 大小, 创建时间)
- ✅ 验证镜像是否正确创建

### 阶段 4: 启动容器
- ✅ 自动检测端口占用
- ✅ 使用指定端口启动容器
- ✅ 等待容器初始化

### 阶段 5: 检查容器状态
- ✅ 显示容器运行状态
- ✅ 验证健康检查状态
- ✅ 等待健康检查通过

### 阶段 6: 验证核心服务
- ✅ SSH 服务状态
- ✅ Cron 服务状态
- ✅ UV 工具版本
- ✅ Python 环境测试

### 阶段 7: 验证项目文件
- ✅ hyperliquid-btc-lag-tracker 项目文件
- ✅ Python 虚拟环境
- ✅ Crontab 配置
- ✅ 定时任务设置

### 阶段 8: 查看日志
- ✅ 显示容器启动日志
- ✅ 检查初始化过程

### 阶段 9: 运行测试任务 (可选)
- ✅ 手动运行 hyperliquid 分析脚本
- ✅ 查看分析日志输出

### 阶段 10: 测试摘要
- ✅ 显示完整的镜像和容器信息
- ✅ 提供常用命令参考
- ✅ 可选清理测试环境

## 命令行参数

| 参数 | 说明 | 示例 |
|------|------|------|
| `--clean` | 清理旧镜像 | `./test-build.sh --clean` |
| `--no-build` | 跳过构建,仅测试现有镜像 | `./test-build.sh --no-build` |
| `--port PORT` | 指定SSH端口映射 | `./test-build.sh --port 3333` |
| `--build-arg ARG` | 传递构建参数 | `./test-build.sh --build-arg LARKBOT_ID="xxx"` |
| `--help` | 显示帮助信息 | `./test-build.sh --help` |

## 输出说明

脚本使用彩色输出来区分不同类型的信息：

- 🔵 **[INFO]** - 信息性消息
- 🟢 **[SUCCESS]** - 成功操作
- 🟡 **[WARNING]** - 警告信息
- 🔴 **[ERROR]** - 错误信息

## 测试完成后

### 保持容器运行

测试完成后可以选择保留容器继续运行，常用命令：

```bash
# 查看容器日志
docker logs akash-ssh-test

# 进入容器
docker exec -it akash-ssh-test /bin/bash

# 查看分析日志
docker exec akash-ssh-test tail -f /root/hyperliquid-btc-lag-tracker-/hyperliquid.log

# 手动运行分析
docker exec akash-ssh-test /root/.local/bin/uv run --directory /root/hyperliquid-btc-lag-tracker- hyperliquid_analyzer.py

# SSH连接 (需先配置 SSH_PUBKEY)
ssh -p 2223 root@localhost
```

### 清理测试环境

```bash
# 停止容器
docker stop akash-ssh-test

# 删除容器
docker rm akash-ssh-test

# 删除镜像
docker rmi ubuntu-akash-ssh:test
```

或者使用一键清理：
```bash
docker stop akash-ssh-test && docker rm akash-ssh-test && docker rmi ubuntu-akash-ssh:test
```

## 高级用法

### 1. 测试不同的 Cron 调度

```bash
./test-build.sh --build-arg CRON_SCHEDULE="*/30 * * * *"  # 每30分钟
./test-build.sh --build-arg CRON_SCHEDULE="0 */1 * * *"   # 每1小时
./test-build.sh --build-arg CRON_SCHEDULE="0 0 * * *"     # 每天0点
```

### 2. 测试自定义 LARKBOT_ID

```bash
./test-build.sh --build-arg LARKBOT_ID="your-custom-bot-id"
```

### 3. 多参数组合

```bash
./test-build.sh \
  --clean \
  --port 3333 \
  --build-arg CRON_SCHEDULE="0 */1 * * *" \
  --build-arg LARKBOT_ID="custom-id"
```

### 4. 使用 SSH 公钥

```bash
# 运行时指定 SSH 公钥
docker run -d \
  --name akash-ssh-test \
  -p 2223:22 \
  -e SSH_PUBKEY="$(cat ~/.ssh/id_rsa.pub)" \
  ubuntu-akash-ssh:test

# 然后可以 SSH 连接
ssh -p 2223 root@localhost
```

## 故障排除

### 问题: 端口已被占用

```bash
# 使用不同端口
./test-build.sh --port 3333
```

### 问题: 健康检查未通过

```bash
# 查看容器日志
docker logs akash-ssh-test

# 检查服务状态
docker exec akash-ssh-test service ssh status
docker exec akash-ssh-test service cron status
```

### 问题: Python 环境错误

```bash
# 检查 UV 安装
docker exec akash-ssh-test /root/.local/bin/uv --version

# 检查虚拟环境
docker exec akash-ssh-test ls -la /root/hyperliquid-btc-lag-tracker-/.venv

# 重新同步依赖
docker exec akash-ssh-test /root/.local/bin/uv sync --directory /root/hyperliquid-btc-lag-tracker-
```

### 问题: Cron 任务未执行

```bash
# 检查 cron 服务
docker exec akash-ssh-test service cron status

# 查看 crontab
docker exec akash-ssh-test crontab -l

# 手动运行任务测试
docker exec akash-ssh-test /root/.local/bin/uv run --directory /root/hyperliquid-btc-lag-tracker- hyperliquid_analyzer.py
```

## 预期结果

成功的测试应该显示：

- ✅ 镜像大小约 900MB
- ✅ 容器健康检查: healthy
- ✅ SSH 服务: running
- ✅ Cron 服务: running
- ✅ UV 版本: 0.9.x
- ✅ Python 环境正常
- ✅ 项目文件完整
- ✅ Crontab 配置正确

## CI/CD 集成

测试脚本可以在 CI/CD 管道中使用：

```yaml
# GitHub Actions 示例
- name: Build and Test
  run: |
    chmod +x test-build.sh
    ./test-build.sh --clean
    # 清理
    docker stop akash-ssh-test || true
    docker rm akash-ssh-test || true
```

## 相关文件

- `test-build.sh` - 主测试脚本
- `Dockerfile` - Docker 镜像定义
- `init.sh` - 容器初始化脚本
- `README.md` - 项目文档
- `.github/workflows/docker-image.yml` - CI/CD 配置

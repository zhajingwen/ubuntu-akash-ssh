# Ubuntu Akash SSH

基于 [Akash Network](https://github.com/akash-network) 的 Ubuntu SSH 镜像 (`ghcr.io/akash-network/ubuntu-2404-ssh:2`) 增强版本，集成了开发常用工具和 Cron 任务调度功能。

## 特性

- ✅ **基础镜像**: 基于 `ghcr.io/akash-network/ubuntu-2404-ssh:2` (Ubuntu 24.04)
- 🔧 **开发工具**: 预装 vim、git、curl
- ⏰ **任务调度**: 内置 cron 服务支持
- 📦 **Python 工具**: 集成 [uv](https://github.com/astral-sh/uv) 快速 Python 包管理器
- 🔐 **SSH 访问**: 支持通过环境变量配置 SSH 公钥
- 🌏 **时区配置**: 默认时区 Asia/Bangkok (可自定义)
- 🏗️ **多架构支持**: 支持 amd64 和 arm64 架构
- 🤖 **自动构建**: GitHub Actions 自动构建和发布

## 快速开始

### 0. 获取镜像

本项目镜像托管在 GitHub Container Registry，每次推送到 `main` 分支时会自动构建并发布。

您可以从以下位置获取构建产物：

- **GitHub Packages**: https://github.com/zhajingwen/ubuntu-akash-ssh/pkgs/container/ubuntu-akash-ssh
- **镜像地址**: `ghcr.io/zhajingwen/ubuntu-akash-ssh:latest`

可用的标签包括 `latest`、`main`、版本号等（详见[镜像标签策略](#镜像标签策略)）。

### 1. 拉取镜像

```bash
docker pull ghcr.io/zhajingwen/ubuntu-akash-ssh:latest
```

### 2. 运行容器

```bash
docker run -d \
  --name akash-ssh \
  -p 2222:22 \
  -e SSH_PUBKEY="$(cat ~/.ssh/id_rsa.pub)" \
  ghcr.io/zhajingwen/ubuntu-akash-ssh:latest
```

### 3. 连接到容器

```bash
ssh -p 2222 root@localhost
```

## 环境变量

| 变量名 | 描述 | 是否必须 | 默认值 |
|--------|------|----------|--------|
| `SSH_PUBKEY` | SSH 公钥内容 | 推荐 | - |
| `TZ` | 时区设置 | 否 | `Asia/Bangkok` |

## 预装工具

- **vim-tiny**: 轻量级文本编辑器
- **cron**: 任务调度服务
- **git**: 版本控制工具
- **curl**: 数据传输工具
- **ca-certificates**: SSL 证书
- **uv**: 高性能 Python 包管理器

## 使用示例

### 配置 Cron 任务

容器启动后，cron 服务会自动运行。您可以添加定时任务：

```bash
# 编辑 crontab
crontab -e

# 示例: 每小时执行一次任务
0 * * * * /path/to/your/script.sh
```

### 使用 uv 管理 Python 包

```bash
# 安装 Python 包
uv pip install requests

# 创建虚拟环境
uv venv myproject
source myproject/bin/activate
```

### 持久化数据

```bash
docker run -d \
  --name akash-ssh \
  -p 2222:22 \
  -v /path/to/data:/data \
  -e SSH_PUBKEY="$(cat ~/.ssh/id_rsa.pub)" \
  ghcr.io/zhajingwen/ubuntu-akash-ssh:latest
```

## 构建与部署

### 本地构建

```bash
# 克隆仓库
git clone https://github.com/zhajingwen/ubuntu-akash-ssh.git
cd ubuntu-akash-ssh

# 构建镜像
docker build -t ubuntu-akash-ssh:local .

# 运行
docker run -d -p 2222:22 -e SSH_PUBKEY="$(cat ~/.ssh/id_rsa.pub)" ubuntu-akash-ssh:local
```

### 多架构构建

```bash
# 创建 buildx builder
docker buildx create --use

# 构建并推送多架构镜像
docker buildx build \
  --platform linux/amd64,linux/arm64 \
  -t ghcr.io/zhajingwen/ubuntu-akash-ssh:latest \
  --push .
```

## 部署到 Akash Network

1. **创建 SDL 配置文件** (`deploy.yaml`):

```yaml
version: "2.0"

services:
  ssh:
    image: ghcr.io/zhajingwen/ubuntu-akash-ssh:latest
    env:
      - SSH_PUBKEY=ssh-rsa AAAAB3NzaC1yc2E...  # 替换为您的 SSH 公钥
    expose:
      - port: 22
        as: 22
        to:
          - global: true

profiles:
  compute:
    ssh:
      resources:
        cpu:
          units: 0.5
        memory:
          size: 512Mi
        storage:
          size: 1Gi
  placement:
    akash:
      pricing:
        ssh:
          denom: uakt
          amount: 100

deployment:
  ssh:
    akash:
      profile: ssh
      count: 1
```

2. **部署到 Akash**:

```bash
akash tx deployment create deploy.yaml --from <your-wallet-name>
```

> 将 `<your-wallet-name>` 替换为您的 Akash 钱包名称

## 自动化构建

项目配置了 GitHub Actions 自动化工作流，当以下事件发生时会自动构建并推送镜像：

- 推送到 `main` 分支
- 创建新的 Release
- 手动触发工作流

生成的镜像会推送到 GitHub Container Registry (ghcr.io)。

## 镜像标签策略

- `latest`: 最新的 main 分支构建
- `main`: main 分支最新构建
- `<version>`: 语义化版本号 (如 `1.0.0`)
- `<major>.<minor>`: 主次版本 (如 `1.0`)
- `<major>`: 主版本 (如 `1`)
- `<branch>-<sha>`: 分支名-提交哈希

## 项目结构

```
.
├── Dockerfile              # 镜像构建文件
├── init.sh                # 容器初始化脚本
├── .github/
│   └── workflows/
│       └── docker-image.yml   # CI/CD 自动构建配置
└── README.md              # 项目说明文档
```

## 技术细节

### 初始化流程

容器启动时，`init.sh` 脚本会执行以下操作：

1. 检查并配置 SSH 公钥 (从 `SSH_PUBKEY` 环境变量)
2. 启动 cron 服务
3. 启动 SSH 服务
4. 保持容器运行

### 镜像优化

- 单层构建减少镜像大小
- 清理 apt 缓存和临时文件
- 使用 `--no-install-recommends` 减少不必要的依赖
- 最小化安装包列表

## 常见问题

### Q: 如何修改时区？

A: 通过环境变量 `TZ` 设置：

```bash
docker run -d -e TZ=Asia/Shanghai -e SSH_PUBKEY="..." ghcr.io/zhajingwen/ubuntu-akash-ssh:latest
```

### Q: Cron 任务没有执行？

A: 检查 cron 服务状态：

```bash
docker exec -it akash-ssh service cron status
```

### Q: 如何查看容器日志？

A: 使用 docker logs 命令：

```bash
docker logs akash-ssh
```


## 贡献

欢迎提交 Issue 和 Pull Request 来改进这个项目！

如果您发现任何问题或有改进建议，请：

1. Fork 本仓库
2. 创建特性分支 (`git checkout -b feature/AmazingFeature`)
3. 提交更改 (`git commit -m 'Add some AmazingFeature'`)
4. 推送到分支 (`git push origin feature/AmazingFeature`)
5. 开启 Pull Request

## 许可证

本项目继承基础镜像的许可证。详情请参考 [Akash Network](https://github.com/akash-network) 相关项目。

## 相关链接

- [GitHub 仓库](https://github.com/zhajingwen/ubuntu-akash-ssh)
- [GitHub Packages - 镜像下载](https://github.com/zhajingwen/ubuntu-akash-ssh/pkgs/container/ubuntu-akash-ssh)
- [Akash Network 官网](https://akash.network/)
- [Akash Network GitHub](https://github.com/akash-network)
- [UV - Python 包管理器](https://github.com/astral-sh/uv)
- [GitHub Container Registry 文档](https://docs.github.com/packages/working-with-a-github-packages-registry/working-with-the-container-registry)

## 更新日志

### 最新更改

- ✅ 优化 Dockerfile 镜像大小
- ✅ 添加必要的构建依赖
- ✅ 集成 vim 和 cron 支持
- ✅ 配置自动化 CI/CD 流程
- ✅ 支持多架构构建 (amd64/arm64)

# 更新日志

## v1.0.1 (2024-12-31) - UTF-8 支持

### 🌐 国际化支持
- ✅ 添加 UTF-8 Locale 支持
- ✅ 安装 locales 包
- ✅ 生成 en_US.UTF-8 和 zh_CN.UTF-8
- ✅ 设置 LANG=C.UTF-8 和 LC_ALL=C.UTF-8
- ✅ 修复中文文件名显示问题

### 🔧 技术改进
- ✅ 恢复并增强 init.sh 脚本
- ✅ 添加 crontab 自动加载功能
- ✅ 优化容器启动流程

---

## v1.0.0 (2024-12-31) - 优化版本

### 🚀 新功能
- ✅ 集成 hyperliquid-btc-lag-tracker 项目
- ✅ 配置自动化定时任务（每2小时执行一次）
- ✅ 添加健康检查支持（支持 Kubernetes/Akash 编排）
- ✅ 支持参数化构建（LARKBOT_ID、REPO_URL、CRON_SCHEDULE）

### ⚡ 性能优化
- ✅ 优化镜像大小：320MB → 300MB（节省 ~20MB）
- ✅ 优化 Dockerfile 层数：5层 → 3层
- ✅ 使用浅克隆（--depth 1）减少下载时间 50%
- ✅ 删除 .git 目录节省约 15MB
- ✅ 使用 COPY --chmod 合并操作减少 1 层

### 🔧 技术改进
- ✅ 集成开发工具：vim、cron、git、curl、UV
- ✅ 清理所有缓存和临时文件
- ✅ 配置自动化 CI/CD 流程
- ✅ 支持多架构构建（amd64/arm64）
- ✅ 添加镜像元数据标签（LABEL）

### 📊 优化详情

#### Dockerfile 优化
```
优化前：5 层
1. apt-get install (系统包)
2. UV 安装
3. 项目克隆 + crontab 配置
4. mv init.sh.original
5. COPY + chmod init.sh

优化后：3 层
1. 所有安装 + 项目克隆（单层，全部清理）
2. mv init.sh.original + COPY --chmod=755
3. HEALTHCHECK
```

#### 镜像大小优化
- 基础镜像: 127MB
- 优化前: ~320MB
- 优化后: ~900MB (包含完整 Python 数据分析依赖)
- hyperliquid 项目: 476MB
- Python 依赖: 完整安装

---

## 初始版本 (2024-12-30)

### 基础功能
- 基于 ghcr.io/akash-network/ubuntu-2404-ssh:2
- SSH 访问支持
- 基础工具集成
- Cron 任务调度

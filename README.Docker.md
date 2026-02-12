# Docker 部署指南

## 快速开始

### 方式 1: 使用 Docker Compose（推荐）

```bash
# 1. 克隆仓库
git clone git@github.com:Ivan99-dev/GoofishCredentialsBot.git
cd GoofishCredentialsBot

# 2. 配置环境变量
cp .env.example .env
# 编辑 .env 文件，填入实际配置

# 3. 启动服务
docker-compose up -d

# 4. 查看日志
docker-compose logs -f

# 5. 访问应用
# 浏览器打开 http://localhost:3000
```

### 方式 2: 使用 Makefile

```bash
# 查看所有可用命令
make help

# 构建并启动
make build
make up

# 查看日志
make logs

# 重启服务
make restart

# 停止服务
make down
```

### 方式 3: 使用预构建镜像

```bash
# 从 GitHub Container Registry 拉取镜像
docker pull ghcr.io/ivan99-dev/goofishcredentialsbot:latest

# 运行容器
docker run -d \
  -p 3000:3000 \
  -v $(pwd)/data:/app/data \
  -v $(pwd)/logs:/app/logs \
  -e NODE_ENV=production \
  --name goofishcbot \
  ghcr.io/ivan99-dev/goofishcredentialsbot:latest
```

### 方式 4: 使用构建脚本

```bash
# 赋予执行权限
chmod +x docker-build.sh

# 执行构建
./docker-build.sh
```

## 环境变量配置

### 必需的环境变量

创建 `.env` 文件：

```bash
# Node 环境
NODE_ENV=production

# 服务端口
PORT=3000

# 时区
TZ=Asia/Shanghai
```

### 可选的环境变量

```bash
# OpenAI API 配置
OPENAI_API_KEY=your_openai_api_key_here
OPENAI_BASE_URL=https://api.openai.com/v1

# API 安全密钥
API_SECRET=your_secret_key_here

# 数据库路径
DB_PATH=./data/goofishcbot.db

# 日志级别
LOG_LEVEL=info
```

## 数据持久化

以下目录会被挂载到宿主机，确保数据持久化：

- `./data` - SQLite 数据库文件
- `./logs` - 应用日志文件

**重要**: 首次运行前，确保这些目录存在：

```bash
mkdir -p data logs
```

## 端口说明

- `3000` - 应用主端口（HTTP + WebSocket）
  - 可在 `docker-compose.yml` 中修改映射端口
  - 例如：`"8080:3000"` 将应用映射到宿主机 8080 端口

## 健康检查

容器内置健康检查，会定期检查 `/api/status` 端点：

```bash
# 查看健康状态
docker inspect --format='{{.State.Health.Status}}' goofishcbot

# 查看健康检查日志
docker inspect --format='{{json .State.Health}}' goofishcbot | jq
```

健康状态说明：
- `starting` - 容器启动中（40秒启动期）
- `healthy` - 服务正常运行
- `unhealthy` - 服务异常（连续3次检查失败）

## 常用命令

### Docker Compose 命令

```bash
# 启动服务（后台运行）
docker-compose up -d

# 启动服务（前台运行，查看日志）
docker-compose up

# 停止服务
docker-compose down

# 停止并删除数据卷
docker-compose down -v

# 重启服务
docker-compose restart

# 查看日志
docker-compose logs -f

# 查看特定服务日志
docker-compose logs -f goofishbot

# 查看服务状态
docker-compose ps

# 进入容器
docker-compose exec goofishbot sh

# 重新构建镜像
docker-compose build --no-cache

# 重新构建并启动
docker-compose up -d --build
```

### Docker 命令

```bash
# 查看运行中的容器
docker ps

# 查看所有容器（包括停止的）
docker ps -a

# 查看容器日志
docker logs -f goofishcbot

# 查看最近100行日志
docker logs --tail 100 goofishcbot

# 进入容器
docker exec -it goofishcbot sh

# 停止容器
docker stop goofishcbot

# 启动容器
docker start goofishcbot

# 重启容器
docker restart goofishcbot

# 删除容器
docker rm goofishcbot

# 删除镜像
docker rmi ghcr.io/ivan99-dev/goofishcredentialsbot:latest
```

## 多架构支持

镜像支持以下架构：
- `linux/amd64` - x86_64 架构（Intel/AMD）
- `linux/arm64` - ARM64 架构（Apple Silicon, ARM服务器）

Docker 会自动选择适合你系统的架构。

### 手动构建多架构镜像

```bash
# 创建 buildx builder
docker buildx create --name mybuilder --use
docker buildx inspect --bootstrap

# 构建多架构镜像
docker buildx build \
  --platform linux/amd64,linux/arm64 \
  -t ghcr.io/ivan99-dev/goofishcredentialsbot:latest \
  --push .
```

## 生产环境部署建议

### 1. 使用反向代理

推荐在前面加 Nginx 或 Traefik：

**Nginx 配置示例**:

```nginx
server {
    listen 80;
    server_name your-domain.com;

    location / {
        proxy_pass http://localhost:3000;
        proxy_http_version 1.1;
        proxy_set_header Upgrade $http_upgrade;
        proxy_set_header Connection 'upgrade';
        proxy_set_header Host $host;
        proxy_cache_bypass $http_upgrade;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto $scheme;
    }
}
```

### 2. 配置 HTTPS

使用 Let's Encrypt 免费证书：

```bash
# 安装 certbot
sudo apt install certbot python3-certbot-nginx

# 获取证书
sudo certbot --nginx -d your-domain.com
```

### 3. 资源限制

在 `docker-compose.yml` 中添加资源限制：

```yaml
services:
  goofishbot:
    # ... 其他配置
    deploy:
      resources:
        limits:
          cpus: '1.0'
          memory: 1G
        reservations:
          cpus: '0.5'
          memory: 512M
```

### 4. 日志管理

已配置日志轮转（最大10MB，保留3个文件）。

查看日志大小：

```bash
docker system df
```

清理日志：

```bash
docker system prune -a
```

### 5. 备份策略

定期备份数据目录：

```bash
# 创建备份
tar -czf backup-$(date +%Y%m%d).tar.gz data/

# 恢复备份
tar -xzf backup-20240101.tar.gz
```

### 6. 监控和告警

使用 Docker 健康检查配合监控工具：

```bash
# 检查容器是否健康
docker inspect --format='{{.State.Health.Status}}' goofishcbot

# 如果不健康，自动重启
docker update --restart=unless-stopped goofishcbot
```

## 故障排查

### 容器无法启动

```bash
# 查看容器日志
docker-compose logs goofishbot

# 查看详细信息
docker inspect goofishcbot

# 检查端口占用
lsof -i :3000
```

### 数据库问题

```bash
# 进入容器检查数据库
docker exec -it goofishcbot sh
ls -la /app/data/

# 检查数据库文件权限
docker exec -it goofishcbot ls -la /app/data/goofishcbot.db
```

### 前端无法访问

```bash
# 检查前端文件是否存在
docker exec -it goofishcbot ls -la /app/public/

# 检查 Nginx 配置（如果使用）
nginx -t
```

### 内存不足

```bash
# 查看容器资源使用
docker stats goofishcbot

# 增加内存限制
# 编辑 docker-compose.yml，增加 memory 限制
```

### 网络问题

```bash
# 检查网络
docker network ls
docker network inspect goofishbot-network

# 重建网络
docker-compose down
docker network prune
docker-compose up -d
```

## 更新应用

### 从源码更新

```bash
# 1. 拉取最新代码
git pull

# 2. 重新构建并启动
docker-compose up -d --build

# 或使用 Makefile
make rebuild
```

### 从镜像更新

```bash
# 1. 拉取最新镜像
docker pull ghcr.io/ivan99-dev/goofishcredentialsbot:latest

# 2. 重启容器
docker-compose down
docker-compose up -d
```

## CI/CD 自动构建

项目配置了 GitHub Actions，会自动构建和发布 Docker 镜像：

- **触发条件**:
  - 推送到 `main` 或 `master` 分支
  - 创建版本标签（如 `v1.0.0`）
  - Pull Request

- **镜像标签**:
  - `latest` - 最新的 main/master 分支
  - `v1.0.0` - 版本标签
  - `main-abc1234` - 分支名-commit SHA

- **镜像地址**:
  ```
  ghcr.io/ivan99-dev/goofishcredentialsbot:latest
  ghcr.io/ivan99-dev/goofishcredentialsbot:v1.0.0
  ```

## 性能优化

### 镜像优化

当前 Dockerfile 已包含以下优化：

- ✅ 多阶段构建，减小最终镜像体积
- ✅ 使用 Alpine Linux 基础镜像
- ✅ 分离前后端构建
- ✅ 只安装生产依赖
- ✅ 使用非 root 用户运行
- ✅ 使用 dumb-init 处理信号
- ✅ 内置健康检查
- ✅ 优化的 .dockerignore
- ✅ 构建缓存优化

### 运行时优化

```yaml
# docker-compose.yml 优化配置
services:
  goofishbot:
    # 使用 host 网络模式（性能更好，但失去网络隔离）
    # network_mode: host

    # 禁用不必要的功能
    security_opt:
      - no-new-privileges:true

    # 只读根文件系统（提高安全性）
    # read_only: true
    # tmpfs:
    #   - /tmp
    #   - /app/logs
```

## 安全建议

1. **不要在镜像中包含敏感信息**
   - 使用环境变量或 Docker secrets
   - 不要提交 `.env` 文件到 Git

2. **定期更新基础镜像**
   ```bash
   docker pull node:20-alpine
   docker-compose build --no-cache
   ```

3. **使用非 root 用户**
   - 已在 Dockerfile 中配置

4. **限制容器权限**
   ```yaml
   security_opt:
     - no-new-privileges:true
   cap_drop:
     - ALL
   ```

5. **扫描镜像漏洞**
   ```bash
   docker scan ghcr.io/ivan99-dev/goofishcredentialsbot:latest
   ```

## 相关链接

- **GitHub 仓库**: https://github.com/Ivan99-dev/GoofishCredentialsBot
- **镜像地址**: https://github.com/Ivan99-dev/GoofishCredentialsBot/pkgs/container/goofishcredentialsbot
- **问题反馈**: https://github.com/Ivan99-dev/GoofishCredentialsBot/issues

## 许可证

查看 [LICENSE](LICENSE) 文件了解详情。

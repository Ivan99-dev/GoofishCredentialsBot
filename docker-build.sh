#!/bin/bash

# Docker 构建脚本

set -e

echo "🐳 开始构建 Goofish Credentials Bot Docker 镜像..."

# 构建镜像
docker build -t goofishcbot:latest .

echo "✅ 镜像构建完成！"
echo ""
echo "运行容器："
echo "  docker-compose up -d"
echo ""
echo "或者直接运行："
echo "  docker run -d -p 3000:3000 -v \$(pwd)/data:/app/data -v \$(pwd)/logs:/app/logs --name goofishcbot goofishcbot:latest"

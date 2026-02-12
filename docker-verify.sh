#!/bin/bash

# Docker 配置验证脚本

set -e

echo "🔍 验证 Docker 配置..."
echo ""

# 检查必需文件
echo "📋 检查必需文件..."
files=(
    "Dockerfile"
    "docker-compose.yml"
    ".dockerignore"
    ".env.example"
    "package.json"
    "frontend/package.json"
)

for file in "${files[@]}"; do
    if [ -f "$file" ]; then
        echo "  ✅ $file"
    else
        echo "  ❌ $file 不存在"
        exit 1
    fi
done

echo ""
echo "🐳 检查 Docker 环境..."

# 检查 Docker
if ! command -v docker &> /dev/null; then
    echo "  ❌ Docker 未安装"
    echo "     请访问 https://docs.docker.com/get-docker/ 安装 Docker"
    exit 1
else
    echo "  ✅ Docker 已安装: $(docker --version)"
fi

# 检查 Docker Compose
if ! command -v docker-compose &> /dev/null; then
    echo "  ⚠️  docker-compose 未安装，尝试使用 docker compose"
    if ! docker compose version &> /dev/null; then
        echo "  ❌ Docker Compose 未安装"
        exit 1
    else
        echo "  ✅ Docker Compose 已安装: $(docker compose version)"
    fi
else
    echo "  ✅ Docker Compose 已安装: $(docker-compose --version)"
fi

# 检查 Docker 是否运行
if ! docker info &> /dev/null; then
    echo "  ❌ Docker 守护进程未运行"
    echo "     请启动 Docker Desktop 或 Docker 服务"
    exit 1
else
    echo "  ✅ Docker 守护进程正在运行"
fi

echo ""
echo "📦 检查项目结构..."

# 检查源码目录
if [ -d "src" ]; then
    echo "  ✅ src/ 目录存在"
else
    echo "  ❌ src/ 目录不存在"
    exit 1
fi

if [ -d "frontend/src" ]; then
    echo "  ✅ frontend/src/ 目录存在"
else
    echo "  ❌ frontend/src/ 目录不存在"
    exit 1
fi

# 创建必要的目录
echo ""
echo "📁 创建数据目录..."
mkdir -p data logs
echo "  ✅ data/ 和 logs/ 目录已创建"

# 检查 .env 文件
echo ""
echo "⚙️  检查环境变量配置..."
if [ -f ".env" ]; then
    echo "  ✅ .env 文件已存在"
else
    echo "  ⚠️  .env 文件不存在，将从 .env.example 复制"
    cp .env.example .env
    echo "  ✅ 已创建 .env 文件，请根据需要修改配置"
fi

echo ""
echo "✅ 所有检查通过！"
echo ""
echo "🚀 可以开始构建了："
echo "   make build    # 或 docker-compose build"
echo "   make up       # 或 docker-compose up -d"
echo ""
echo "📖 更多信息请查看 README.Docker.md"

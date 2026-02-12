#!/bin/bash

# 本地 Docker 构建和测试脚本

set -e

echo "🚀 开始本地 Docker 构建和测试..."
echo ""

# 1. 验证配置
echo "📋 步骤 1/5: 验证配置..."
./docker-verify.sh
echo ""

# 2. 构建镜像
echo "🔨 步骤 2/5: 构建 Docker 镜像..."
docker-compose build
echo "✅ 镜像构建完成"
echo ""

# 3. 启动服务
echo "🚀 步骤 3/5: 启动服务..."
docker-compose up -d
echo "✅ 服务已启动"
echo ""

# 4. 等待服务就绪
echo "⏳ 步骤 4/5: 等待服务就绪..."
sleep 10

# 检查健康状态
for i in {1..30}; do
    if curl -f http://localhost:3000/api/status &>/dev/null; then
        echo "✅ 服务健康检查通过"
        break
    fi
    if [ $i -eq 30 ]; then
        echo "❌ 服务启动超时"
        docker-compose logs
        exit 1
    fi
    echo "等待中... ($i/30)"
    sleep 2
done
echo ""

# 5. 显示状态
echo "📊 步骤 5/5: 服务状态..."
docker-compose ps
echo ""

echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""
echo "✅ 本地测试完成！"
echo ""
echo "🌐 访问地址:"
echo "   应用: http://localhost:3000"
echo "   健康检查: http://localhost:3000/api/status"
echo ""
echo "📋 常用命令:"
echo "   查看日志: docker-compose logs -f"
echo "   停止服务: docker-compose down"
echo "   重启服务: docker-compose restart"
echo "   进入容器: docker-compose exec goofishbot sh"
echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"

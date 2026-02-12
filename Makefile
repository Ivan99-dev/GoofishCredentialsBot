.PHONY: help build up down restart logs clean test

# 默认目标
help:
	@echo "Goofish Credentials Bot - Docker 管理命令"
	@echo ""
	@echo "使用方法: make [target]"
	@echo ""
	@echo "可用命令:"
	@echo "  build      - 构建 Docker 镜像"
	@echo "  up         - 启动容器"
	@echo "  down       - 停止并删除容器"
	@echo "  restart    - 重启容器"
	@echo "  logs       - 查看容器日志"
	@echo "  shell      - 进入容器 shell"
	@echo "  clean      - 清理镜像和容器"
	@echo "  rebuild    - 重新构建并启动"
	@echo "  status     - 查看容器状态"

# 构建镜像
build:
	@echo "🐳 构建 Docker 镜像..."
	docker-compose build

# 启动容器
up:
	@echo "🚀 启动容器..."
	docker-compose up -d
	@echo "✅ 容器已启动！访问 http://localhost:3000"

# 停止容器
down:
	@echo "🛑 停止容器..."
	docker-compose down

# 重启容器
restart:
	@echo "🔄 重启容器..."
	docker-compose restart

# 查看日志
logs:
	docker-compose logs -f

# 进入容器 shell
shell:
	docker-compose exec goofishbot sh

# 清理
clean:
	@echo "🧹 清理容器和镜像..."
	docker-compose down -v
	docker rmi goofishcbot:latest || true

# 重新构建并启动
rebuild: clean build up

# 查看状态
status:
	@echo "📊 容器状态:"
	@docker-compose ps
	@echo ""
	@echo "💾 磁盘使用:"
	@docker system df

# 多阶段构建 Dockerfile for Goofish Credentials Bot

# Build arguments
ARG NODE_VERSION=20
ARG BUILD_DATE
ARG VCS_REF

# Stage 1: 构建前端
FROM node:${NODE_VERSION}-alpine AS frontend-builder

WORKDIR /app/frontend

# 复制前端依赖文件
COPY frontend/package*.json ./

# 安装前端依赖（使用 npm install 而不是 ci，因为可能没有 package-lock.json）
RUN npm install --prefer-offline --no-audit

# 复制前端源码
COPY frontend/ ./

# 构建前端
RUN npm run build

# Stage 2: 构建后端
FROM node:${NODE_VERSION}-alpine AS backend-builder

WORKDIR /app

# 复制后端依赖文件
COPY package*.json ./
COPY tsconfig.json ./

# 安装后端依赖（包括 devDependencies 用于构建）
RUN npm install --prefer-offline --no-audit

# 复制后端源码
COPY src/ ./src/

# 构建后端
RUN npm run build

# Stage 3: 生产镜像
FROM node:${NODE_VERSION}-alpine

# 添加标签
LABEL org.opencontainers.image.title="Goofish Credentials Bot"
LABEL org.opencontainers.image.description="Goofish 闲鱼凭证机器人"
LABEL org.opencontainers.image.authors="Ivan99-dev"
LABEL org.opencontainers.image.source="https://github.com/Ivan99-dev/GoofishCredentialsBot"
LABEL org.opencontainers.image.created="${BUILD_DATE}"
LABEL org.opencontainers.image.revision="${VCS_REF}"

WORKDIR /app

# 安装 dumb-init 用于正确处理信号
RUN apk add --no-cache dumb-init

# 创建非 root 用户
RUN addgroup -g 1001 -S nodejs && \
    adduser -S nodejs -u 1001

# 复制后端依赖文件
COPY package*.json ./

# 只安装生产依赖
RUN npm install --only=production --prefer-offline --no-audit && \
    npm cache clean --force

# 从构建阶段复制编译后的后端代码
COPY --from=backend-builder /app/dist ./dist

# 从构建阶段复制前端构建产物
COPY --from=frontend-builder /app/frontend/dist/frontend/browser ./public

# 复制其他必要文件
COPY ecosystem.config.cjs ./

# 创建数据和日志目录
RUN mkdir -p data logs && \
    chown -R nodejs:nodejs /app

# 切换到非 root 用户
USER nodejs

# 暴露端口
EXPOSE 3000

# 健康检查
HEALTHCHECK --interval=30s --timeout=3s --start-period=40s --retries=3 \
    CMD node -e "require('http').get('http://localhost:3000/api/status', (r) => {process.exit(r.statusCode === 200 ? 0 : 1)})"

# 使用 dumb-init 启动应用
ENTRYPOINT ["dumb-init", "--"]
CMD ["node", "dist/index.js"]

# GitHub Pages 配置指南

## ❌ 当前问题

GitHub Actions 中的 `docs.yml` 工作流失败，错误信息：
```
Get Pages site failed. Please verify that the repository has Pages enabled
```

这是因为 GitHub Pages 功能未启用。

---

## ✅ 解决方案

### 步骤 1: 启用 GitHub Pages

1. 访问你的仓库设置：
   https://github.com/Ivan99-dev/GoofishCredentialsBot/settings/pages

2. 在 "Build and deployment" 部分：
   - **Source**: 选择 `GitHub Actions`
   - 点击 Save

### 步骤 2: 重新运行工作流

1. 访问 Actions 页面：
   https://github.com/Ivan99-dev/GoofishCredentialsBot/actions

2. 找到失败的 "Deploy VitePress to GitHub Pages" 工作流

3. 点击 "Re-run all jobs"

---

## 🔧 或者：禁用 Pages 工作流

如果你不需要文档站点，可以禁用或删除 Pages 工作流：

### 方式 1: 禁用工作流

1. 访问：https://github.com/Ivan99-dev/GoofishCredentialsBot/actions

2. 找到 "Deploy VitePress to GitHub Pages" 工作流

3. 点击右上角的 "..." 菜单

4. 选择 "Disable workflow"

### 方式 2: 删除工作流文件

```bash
# 删除 docs 工作流
rm .github/workflows/docs.yml

# 提交并推送
git add .github/workflows/docs.yml
git commit -m "chore: 移除 GitHub Pages 工作流"
git push origin main
```

---

## 📊 当前工作流状态

你的仓库有两个工作流：

1. ✅ **Docker Build and Push** - 正常运行
   - 构建 Docker 镜像
   - 发布到 GitHub Container Registry
   - 这个是你需要的

2. ❌ **Deploy VitePress to GitHub Pages** - 失败
   - 部署文档站点
   - 需要启用 Pages 功能
   - 如果不需要可以禁用

---

## 💡 推荐操作

### 如果你需要文档站点：
按照上面的步骤 1 和 2 启用 GitHub Pages

### 如果你不需要文档站点：
运行以下命令删除工作流：

```bash
rm .github/workflows/docs.yml
git add .github/workflows/docs.yml
git commit -m "chore: 移除 GitHub Pages 工作流"
git push origin main
```

---

## 🔗 相关链接

- **仓库设置**: https://github.com/Ivan99-dev/GoofishCredentialsBot/settings
- **Pages 设置**: https://github.com/Ivan99-dev/GoofishCredentialsBot/settings/pages
- **Actions 页面**: https://github.com/Ivan99-dev/GoofishCredentialsBot/actions
- **Docker 工作流**: https://github.com/Ivan99-dev/GoofishCredentialsBot/actions/workflows/docker.yml

---

## ✅ Docker 构建状态

重要的是 Docker 构建工作流应该正常运行。检查：
https://github.com/Ivan99-dev/GoofishCredentialsBot/actions/workflows/docker.yml

如果 Docker 构建成功，你就可以使用镜像了：
```bash
docker pull ghcr.io/ivan99-dev/goofishcredentialsbot:latest
```

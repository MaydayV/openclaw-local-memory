# 发布到 GitHub 指南

## 方法 1：使用 GitHub CLI（推荐）

### 1. 登录 GitHub CLI

```bash
gh auth login
```

按照提示完成登录。

### 2. 创建并推送仓库

```bash
cd ~/.openclaw/workspace/skills/local-memory-setup

gh repo create openclaw-local-memory \
  --public \
  --source=. \
  --remote=origin \
  --push \
  --description="OpenClaw 本地记忆系统配置指南 - 使用 Ollama + Qwen3 Embedding 实现完全本地化的语义搜索"
```

## 方法 2：手动创建仓库

### 1. 在 GitHub 网站创建仓库

1. 访问 https://github.com/new
2. 仓库名称：`openclaw-local-memory`
3. 描述：`OpenClaw 本地记忆系统配置指南 - 使用 Ollama + Qwen3 Embedding 实现完全本地化的语义搜索`
4. 选择 Public
5. 不要初始化 README、.gitignore 或 LICENSE（我们已经有了）
6. 点击 "Create repository"

### 2. 推送到 GitHub

```bash
cd ~/.openclaw/workspace/skills/local-memory-setup

# 添加远程仓库（替换 YOUR_USERNAME）
git remote add origin https://github.com/YOUR_USERNAME/openclaw-local-memory.git

# 推送到 GitHub
git push -u origin main
```

## 方法 3：使用 SSH

### 1. 配置 SSH Key（如果还没有）

```bash
# 生成 SSH key
ssh-keygen -t ed25519 -C "your_email@example.com"

# 添加到 ssh-agent
eval "$(ssh-agent -s)"
ssh-add ~/.ssh/id_ed25519

# 复制公钥
cat ~/.ssh/id_ed25519.pub
```

将公钥添加到 GitHub：https://github.com/settings/keys

### 2. 推送到 GitHub

```bash
cd ~/.openclaw/workspace/skills/local-memory-setup

# 添加远程仓库（替换 YOUR_USERNAME）
git remote add origin git@github.com:YOUR_USERNAME/openclaw-local-memory.git

# 推送到 GitHub
git push -u origin main
```

## 验证

推送成功后，访问：
```
https://github.com/YOUR_USERNAME/openclaw-local-memory
```

应该看到所有文件和 README。

## 分享给朋友

### 克隆仓库

```bash
git clone https://github.com/YOUR_USERNAME/openclaw-local-memory.git
cd openclaw-local-memory
```

### 快速安装

```bash
# 方法 1：一键安装
./install.sh

# 方法 2：手动安装
# 查看 QUICKSTART.md
cat QUICKSTART.md
```

### 查看文档

```bash
# 完整文档
cat README.md

# 快速开始
cat QUICKSTART.md

# 配置示例
cat config-example.json
```

## 更新仓库

如果你修改了文件，推送更新：

```bash
cd ~/.openclaw/workspace/skills/local-memory-setup

# 添加修改
git add .

# 提交
git commit -m "Update: 描述你的修改"

# 推送
git push
```

## 创建 Release（可选）

### 使用 GitHub CLI

```bash
gh release create v1.0.0 \
  --title "v1.0.0 - Initial Release" \
  --notes "首个正式版本

特性：
- 完整的安装和配置指南
- 自动化安装脚本
- 故障排查和最佳实践
- 性能优化建议"
```

### 手动创建

1. 访问 https://github.com/YOUR_USERNAME/openclaw-local-memory/releases/new
2. Tag version: `v1.0.0`
3. Release title: `v1.0.0 - Initial Release`
4. 描述：添加 release notes
5. 点击 "Publish release"

## 分享链接

将以下链接发送给你的朋友：

**仓库地址：**
```
https://github.com/YOUR_USERNAME/openclaw-local-memory
```

**一键安装：**
```bash
curl -fsSL https://raw.githubusercontent.com/YOUR_USERNAME/openclaw-local-memory/main/install.sh | bash
```

**克隆仓库：**
```bash
git clone https://github.com/YOUR_USERNAME/openclaw-local-memory.git
```

---

**提示：** 记得将 `YOUR_USERNAME` 替换为你的 GitHub 用户名！

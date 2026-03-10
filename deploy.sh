#!/bin/bash
# 快速发布脚本 - openclaw-local-memory

echo "🦞 OpenClaw Local Memory - 快速发布到 GitHub"
echo "=============================================="
echo ""
echo "📋 步骤 1：创建 GitHub 仓库"
echo ""
echo "请在浏览器中打开以下链接："
echo "👉 https://github.com/new"
echo ""
echo "填写以下信息："
echo "  - Repository name: openclaw-local-memory"
echo "  - Description: OpenClaw 本地记忆系统配置指南 - 使用 Ollama + Qwen3 Embedding 实现完全本地化的语义搜索"
echo "  - 选择: Public"
echo "  - 不要勾选任何初始化选项（README, .gitignore, LICENSE）"
echo ""
echo "创建完成后，按 Enter 继续..."
read

echo ""
echo "🚀 步骤 2：推送代码到 GitHub"
echo ""

cd ~/.openclaw/workspace/skills/local-memory-setup

# 添加远程仓库
echo "添加远程仓库..."
git remote add origin https://github.com/MaydayV/openclaw-local-memory.git 2>/dev/null || echo "远程仓库已存在"

# 推送到 GitHub
echo "推送代码..."
git push -u origin main

if [ $? -eq 0 ]; then
    echo ""
    echo "✅ 发布成功！"
    echo ""
    echo "📦 仓库地址："
    echo "https://github.com/MaydayV/openclaw-local-memory"
    echo ""
    echo "📤 分享给朋友："
    echo ""
    echo "一键安装："
    echo "curl -fsSL https://raw.githubusercontent.com/MaydayV/openclaw-local-memory/main/install.sh | bash"
    echo ""
    echo "克隆仓库："
    echo "git clone https://github.com/MaydayV/openclaw-local-memory.git"
    echo ""
else
    echo ""
    echo "❌ 推送失败"
    echo ""
    echo "可能的原因："
    echo "1. 仓库还没有创建"
    echo "2. 需要 GitHub 认证"
    echo ""
    echo "解决方案："
    echo "1. 确保已在 GitHub 创建仓库"
    echo "2. 运行: gh auth login"
    echo "3. 或者使用 SSH: git remote set-url origin git@github.com:MaydayV/openclaw-local-memory.git"
fi

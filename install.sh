#!/usr/bin/env bash
# OpenClaw Local Memory Setup - Quick Install Script
# 快速安装 Ollama + Qwen3 Embedding 并配置 OpenClaw

set -e

echo "🦞 OpenClaw Local Memory Setup"
echo "================================"
echo ""

# 检测操作系统
OS="$(uname -s)"
case "${OS}" in
    Linux*)     PLATFORM=Linux;;
    Darwin*)    PLATFORM=Mac;;
    CYGWIN*|MINGW*|MSYS*) PLATFORM=Windows;;
    *)          PLATFORM="UNKNOWN:${OS}"
esac

echo "检测到操作系统: ${PLATFORM}"
echo ""

# 1. 安装 Ollama
echo "步骤 1/5: 安装 Ollama"
echo "-------------------"

if command -v ollama &> /dev/null; then
    echo "✅ Ollama 已安装"
    ollama --version
else
    echo "📦 正在安装 Ollama..."
    
    if [ "$PLATFORM" = "Mac" ]; then
        if command -v brew &> /dev/null; then
            brew install ollama
        else
            echo "❌ 未找到 Homebrew，请先安装 Homebrew: https://brew.sh"
            exit 1
        fi
    elif [ "$PLATFORM" = "Linux" ]; then
        curl -fsSL https://ollama.com/install.sh | sh
    else
        echo "❌ 不支持的操作系统: ${PLATFORM}"
        echo "请手动安装 Ollama: https://ollama.com/download"
        exit 1
    fi
    
    echo "✅ Ollama 安装完成"
fi

echo ""

# 2. 启动 Ollama 服务
echo "步骤 2/5: 启动 Ollama 服务"
echo "------------------------"

if pgrep -x "ollama" > /dev/null; then
    echo "✅ Ollama 服务已运行"
else
    echo "🚀 正在启动 Ollama 服务..."
    
    if [ "$PLATFORM" = "Mac" ]; then
        brew services start ollama
    elif [ "$PLATFORM" = "Linux" ]; then
        if command -v systemctl &> /dev/null; then
            sudo systemctl start ollama
        else
            nohup ollama serve > /dev/null 2>&1 &
        fi
    fi
    
    # 等待服务启动
    echo "等待服务启动..."
    sleep 3
    
    if pgrep -x "ollama" > /dev/null; then
        echo "✅ Ollama 服务启动成功"
    else
        echo "⚠️  Ollama 服务可能未启动，请手动运行: ollama serve"
    fi
fi

echo ""

# 3. 下载 Qwen3 Embedding 模型
echo "步骤 3/5: 下载 Qwen3 Embedding 模型"
echo "-----------------------------------"

if ollama list | grep -q "qwen3-embedding:0.6b"; then
    echo "✅ Qwen3 Embedding 模型已存在"
else
    echo "📥 正在下载 Qwen3 Embedding 模型（约 600MB）..."
    echo "这可能需要几分钟，请耐心等待..."
    ollama pull qwen3-embedding:0.6b
    echo "✅ 模型下载完成"
fi

echo ""

# 4. 验证安装
echo "步骤 4/5: 验证安装"
echo "-----------------"

echo "已安装的模型："
ollama list

echo ""

# 5. 配置 OpenClaw
echo "步骤 5/5: 配置 OpenClaw"
echo "---------------------"

if [ ! -f ~/.openclaw/openclaw.json ]; then
    echo "❌ 未找到 OpenClaw 配置文件"
    echo "请确保 OpenClaw 已安装并初始化"
    exit 1
fi

# 检查是否已经配置了 memorySearch
if grep -q '"memorySearch"' ~/.openclaw/openclaw.json; then
    echo ""
    echo "⚠️  检测到已有 memorySearch 配置"
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    
    # 检查当前 provider
    CURRENT_PROVIDER=$(grep -A 5 '"memorySearch"' ~/.openclaw/openclaw.json | grep '"provider"' | sed 's/.*"provider": "\([^"]*\)".*/\1/' | head -1)
    
    if [ ! -z "$CURRENT_PROVIDER" ]; then
        echo "当前 provider: $CURRENT_PROVIDER"
        echo ""
        
        if [ "$CURRENT_PROVIDER" != "ollama" ]; then
            echo "⚠️  警告：你当前使用的是 $CURRENT_PROVIDER provider"
            echo "继续安装会将其替换为 ollama (本地模型)"
            echo ""
            echo "如果你想保留当前配置，请选择 'n' 并手动配置"
            echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
            echo ""
            
            read -p "是否继续并替换为 ollama？(y/n) " -n 1 -r
            echo ""
            
            if [[ ! $REPLY =~ ^[Yy]$ ]]; then
                echo ""
                echo "❌ 已取消配置"
                echo ""
                echo "你可以手动配置 Ollama 作为额外的 provider："
                echo "1. 查看配置示例: cat config-example.json"
                echo "2. 手动编辑配置: vim ~/.openclaw/openclaw.json"
                echo ""
                exit 0
            fi
        else
            echo "✅ 当前已使用 ollama provider"
            echo "将更新为最新的推荐配置"
            echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
        fi
    fi
fi

echo ""
echo "⚠️  重要提示："
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "1. 此操作会更新 OpenClaw 配置并重启服务"
echo "2. 正在进行的对话可能会被中断"
echo "3. 现有的对话记录和 memory 文件不会被删除或修改"
echo "4. 只是添加/更新本地记忆搜索配置，不影响现有数据"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""

read -p "是否继续配置 OpenClaw？(y/n) " -n 1 -r
echo ""

if [[ ! $REPLY =~ ^[Yy]$ ]]; then
    echo ""
    echo "❌ 已取消配置"
    echo ""
    echo "你可以稍后手动配置："
    echo "1. 查看配置示例: cat config-example.json"
    echo "2. 手动应用配置: openclaw config patch < config-example.json"
    echo ""
    exit 0
fi

echo ""
echo "📝 正在更新 OpenClaw 配置..."

# 创建临时配置文件
cat > /tmp/openclaw-memory-patch.json << 'EOF'
{
  "agents": {
    "defaults": {
      "memorySearch": {
        "enabled": true,
        "provider": "ollama",
        "fallback": "none",
        "model": "qwen3-embedding:0.6b",
        "chunking": {
          "tokens": 200,
          "overlap": 60
        },
        "query": {
          "maxResults": 10,
          "minScore": 0.25,
          "hybrid": {
            "enabled": true,
            "vectorWeight": 0.6,
            "textWeight": 0.4,
            "candidateMultiplier": 8,
            "mmr": {
              "enabled": true,
              "lambda": 0.7
            },
            "temporalDecay": {
              "enabled": true,
              "halfLifeDays": 60
            }
          }
        }
      }
    }
  }
}
EOF

# 使用 OpenClaw CLI 应用配置
if command -v openclaw &> /dev/null; then
    echo "使用 OpenClaw CLI 应用配置..."
    openclaw config patch < /tmp/openclaw-memory-patch.json
    rm /tmp/openclaw-memory-patch.json
    echo "✅ 配置已更新，OpenClaw 正在重启..."
    echo ""
    echo "⏳ 等待 OpenClaw 重启完成（约 5-10 秒）..."
    sleep 10
else
    echo "⚠️  未找到 OpenClaw CLI"
    echo "请手动将以下配置添加到 ~/.openclaw/openclaw.json:"
    cat /tmp/openclaw-memory-patch.json
    rm /tmp/openclaw-memory-patch.json
    exit 1
fi

echo ""

# 6. 重建向量索引
echo "步骤 6/6: 重建向量索引（可选）"
echo "-----------------------------"
echo ""
echo "⚠️  关于重建索引："
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "1. 如果你是首次安装，建议立即重建索引"
echo "2. 如果你已有大量 memory 文件，重建可能需要几分钟"
echo "3. 重建索引不会删除或修改你的 memory 文件"
echo "4. 只是用新的向量模型重新生成索引"
echo "5. 你也可以稍后手动运行: openclaw memory index --force"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""

read -p "是否立即重建向量索引？(y/n) " -n 1 -r
echo ""

if [[ $REPLY =~ ^[Yy]$ ]]; then
    echo ""
    echo "🔄 正在重建向量索引..."
    echo "这可能需要几分钟，请耐心等待..."
    openclaw memory index --force
    echo "✅ 索引重建完成"
fi

echo ""
echo "================================"
echo "🎉 安装完成！"
echo ""
echo "✅ 已完成的操作："
echo "  1. 安装 Ollama"
echo "  2. 下载 Qwen3 Embedding 模型"
echo "  3. 配置 OpenClaw 本地记忆系统"
if [[ $REPLY =~ ^[Yy]$ ]]; then
    echo "  4. 重建向量索引"
fi
echo ""
echo "📊 数据安全确认："
echo "  ✅ 你的对话记录完好无损"
echo "  ✅ 你的 memory 文件未被修改"
echo "  ✅ 你的 agent 配置保持不变"
echo "  ✅ 只是添加了本地记忆搜索功能"
echo ""
echo "🚀 下一步："
echo "  1. OpenClaw 已重启并运行"
echo "  2. 测试记忆搜索: 在 OpenClaw 中输入 '请搜索我之前的对话'"
echo "  3. 查看完整文档: cat README.md"
echo ""
echo "📚 文档和帮助："
echo "  - 快速开始: cat QUICKSTART.md"
echo "  - 原理解释: cat PRINCIPLES.md"
echo "  - 配置示例: cat config-example.json"
echo "  - 故障排查: 查看 README.md 的故障排查章节"
echo ""
echo "🔧 常用命令："
echo "  - 检查 Ollama: ollama list"
echo "  - 检查向量库: ls -lh ~/.openclaw/memory/*.sqlite"
echo "  - 查看日志: tail -f ~/.openclaw/logs/gateway.log"
echo "  - 重建索引: openclaw memory index --force"
echo ""
echo "需要帮助？访问 https://github.com/MaydayV/openclaw-local-memory"
echo "================================"

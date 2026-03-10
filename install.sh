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
    echo "✅ 配置已更新"
else
    echo "⚠️  未找到 OpenClaw CLI"
    echo "请手动将以下配置添加到 ~/.openclaw/openclaw.json:"
    cat /tmp/openclaw-memory-patch.json
    rm /tmp/openclaw-memory-patch.json
fi

echo ""

# 6. 重建向量索引
echo "步骤 6/5: 重建向量索引（可选）"
echo "-----------------------------"

read -p "是否立即重建向量索引？(y/n) " -n 1 -r
echo ""

if [[ $REPLY =~ ^[Yy]$ ]]; then
    echo "🔄 正在重建向量索引..."
    openclaw memory index --force
    echo "✅ 索引重建完成"
fi

echo ""
echo "================================"
echo "🎉 安装完成！"
echo ""
echo "下一步："
echo "1. 重启 OpenClaw（如果正在运行）"
echo "2. 测试记忆搜索功能"
echo "3. 查看完整文档: ~/.openclaw/workspace/skills/local-memory-setup/README.md"
echo ""
echo "测试命令："
echo "  在 OpenClaw 中输入: 请搜索我之前的对话"
echo ""
echo "故障排查："
echo "  检查 Ollama 状态: ollama list"
echo "  检查向量数据库: ls -lh ~/.openclaw/memory/*.sqlite"
echo "  查看日志: tail -f ~/.openclaw/logs/gateway.log"
echo ""
echo "需要帮助？查看 README.md 或访问 https://docs.openclaw.ai"
echo "================================"

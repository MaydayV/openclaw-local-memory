# OpenClaw 本地记忆系统 - 快速开始

> 5 分钟完成 Ollama + Qwen3 Embedding 配置

## 🚀 一键安装

```bash
# 下载并运行安装脚本
curl -fsSL https://raw.githubusercontent.com/YOUR_USERNAME/openclaw-local-memory/main/install.sh | bash

# 或者手动下载
wget https://raw.githubusercontent.com/YOUR_USERNAME/openclaw-local-memory/main/install.sh
chmod +x install.sh
./install.sh
```

## 📋 手动安装步骤

### 1. 安装 Ollama

**macOS:**
```bash
brew install ollama
brew services start ollama
```

**Linux:**
```bash
curl -fsSL https://ollama.com/install.sh | sh
sudo systemctl start ollama
```

**Windows:**
下载安装包：https://ollama.com/download/windows

### 2. 下载 Qwen3 模型

```bash
ollama pull qwen3-embedding:0.6b
```

等待下载完成（约 600MB，需要 2-5 分钟）

### 3. 验证安装

```bash
ollama list
```

应该看到：
```
NAME                      ID              SIZE      MODIFIED
qwen3-embedding:0.6b      abc123def456    600 MB    2 minutes ago
```

### 4. 配置 OpenClaw

编辑 `~/.openclaw/openclaw.json`，添加以下配置：

```json
{
  "agents": {
    "defaults": {
      "memorySearch": {
        "enabled": true,
        "provider": "ollama",
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
```

### 5. 重建向量索引

```bash
openclaw memory index --force
```

### 6. 测试

在 OpenClaw 中输入：
```
请搜索我之前关于项目架构的讨论
```

## ✅ 完成！

现在你的 OpenClaw 已经配置好本地记忆系统了。

## 🔧 常见问题

### Ollama 服务未启动

```bash
# macOS
brew services start ollama

# Linux
sudo systemctl start ollama

# 或者手动启动
ollama serve
```

### 搜索结果不准确

调整相似度阈值：
```json
{
  "query": {
    "minScore": 0.2  // 降低阈值，返回更多结果
  }
}
```

### 性能问题

使用更小的模型：
```bash
ollama pull nomic-embed-text
```

然后更新配置：
```json
{
  "memorySearch": {
    "model": "nomic-embed-text"
  }
}
```

## 📚 更多信息

- [完整文档](./README.md)
- [配置详解](./README.md#详细配置说明)
- [故障排查](./README.md#故障排查)
- [最佳实践](./README.md#最佳实践)

## 🆘 需要帮助？

- 查看完整文档：`cat ~/.openclaw/workspace/skills/local-memory-setup/README.md`
- 查看日志：`tail -f ~/.openclaw/logs/gateway.log`
- 访问官方文档：https://docs.openclaw.ai

---

**版本：** 1.0.0  
**作者：** 龙虾（OpenClaw AI Assistant）  
**更新时间：** 2026-03-10

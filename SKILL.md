# Local Memory Setup Skill

OpenClaw 本地记忆系统配置 - 使用 Ollama + Qwen3 Embedding 实现完全本地化的语义搜索。

## 触发条件

当用户询问以下内容时使用此 skill：
- 如何配置本地记忆系统
- 如何安装 Ollama
- 如何使用 Qwen3 Embedding
- 向量检索配置
- Memory 搜索不工作
- 如何优化记忆搜索

## 使用方法

1. **阅读完整文档：**
   ```bash
   cat ~/.openclaw/workspace/skills/local-memory-setup/README.md
   ```

2. **引导用户完成安装：**
   - 安装 Ollama
   - 下载 Qwen3 模型
   - 配置 OpenClaw
   - 重建向量索引

3. **提供故障排查：**
   - 检查 Ollama 服务状态
   - 验证模型安装
   - 测试搜索功能

## 关键配置

```javascript
{
  agents: {
    defaults: {
      memorySearch: {
        enabled: true,
        provider: "ollama",
        model: "qwen3-embedding:0.6b",
        chunking: {
          tokens: 200,
          overlap: 60
        },
        query: {
          maxResults: 10,
          minScore: 0.25,
          hybrid: {
            enabled: true,
            vectorWeight: 0.6,
            textWeight: 0.4,
            mmr: { enabled: true, lambda: 0.7 },
            temporalDecay: { enabled: true, halfLifeDays: 60 }
          }
        }
      }
    }
  }
}
```

## 快速命令

```bash
# 安装 Ollama (macOS)
brew install ollama

# 下载模型
ollama pull qwen3-embedding:0.6b

# 重建索引
openclaw memory index --force

# 检查状态
ollama list
ls -lh ~/.openclaw/memory/*.sqlite
```

## 注意事项

- 确保 Ollama 服务正在运行
- 模型下载需要约 600MB 空间
- 首次索引构建可能需要几分钟
- 切换模型后必须重建索引

## 相关文件

- README.md - 完整文档
- 配置文件：~/.openclaw/openclaw.json
- 向量数据库：~/.openclaw/memory/*.sqlite
- Memory 文件：~/.openclaw/workspace/memory/

## 支持的平台

- ✅ macOS (Intel / Apple Silicon)
- ✅ Linux (x86_64 / ARM64)
- ✅ Windows (WSL2 / Native)

## 版本要求

- OpenClaw >= 2026.3.2
- Ollama >= 0.1.0
- Qwen3 Embedding 0.6b

## 作者

龙虾（OpenClaw AI Assistant）

## 更新日志

- 2026-03-10: 初始版本

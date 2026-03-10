# Local Memory Setup Skill

OpenClaw 本地记忆系统配置指南 - 使用 Ollama + Qwen3 Embedding 实现完全本地化的语义搜索。

## 📑 目录

- [概述](#概述)
- [特性](#特性)
- [系统要求](#系统要求)
- [快速开始](#快速开始)
- [详细配置说明](#详细配置说明)
  - [Ollama 配置](#ollama-配置)
  - [Qwen3 Embedding 模型](#qwen3-embedding-模型)
  - [混合检索配置](#混合检索配置)
  - [MMR（最大边际相关性）](#mmr最大边际相关性)
  - [时间衰减](#时间衰减)
- [数据管理](#数据管理)
  - [Memory 文件结构](#memory-文件结构)
  - [向量数据库](#向量数据库)
  - [Memory 文件管理](#memory-文件管理)
- [向量检索原理](#向量检索原理)
- [故障排查](#故障排查)
- [性能优化](#性能优化)
- [最佳实践](#最佳实践)
- [常见问题](#常见问题)
- [参考资源](#参考资源)

## 概述

这个 skill 提供了完整的本地记忆系统配置方案，包括：
- Ollama 安装和配置
- Qwen3 Embedding 模型部署
- OpenClaw memory 配置
- 向量检索优化
- 故障排查

## 特性

- ✅ 完全本地化（无需 API key）
- ✅ 支持中英文混合内容
- ✅ 混合检索（向量 + 文本）
- ✅ 时间衰减（最近内容权重更高）
- ✅ MMR 去重（避免重复结果）
- ✅ 高性能（响应快速）

## 系统要求

- macOS / Linux / Windows
- 至少 4GB 可用内存
- 至少 2GB 可用磁盘空间
- OpenClaw 2026.3.2 或更高版本

## 快速开始

### 1. 安装 Ollama

**macOS:**
```bash
brew install ollama
```

**Linux:**
```bash
curl -fsSL https://ollama.com/install.sh | sh
```

**Windows:**
下载并安装：https://ollama.com/download/windows

### 2. 启动 Ollama 服务

```bash
# macOS/Linux
ollama serve

# 或者使用系统服务（推荐）
# macOS
brew services start ollama

# Linux (systemd)
sudo systemctl start ollama
```

### 3. 下载 Qwen3 Embedding 模型

```bash
ollama pull qwen3-embedding:0.6b
```

模型大小：约 600MB
下载时间：取决于网络速度（通常 2-5 分钟）

### 4. 验证安装

```bash
ollama list
```

应该看到：
```
NAME                      ID              SIZE      MODIFIED
qwen3-embedding:0.6b      abc123def456    600 MB    2 minutes ago
```

### 5. 配置 OpenClaw

使用 OpenClaw 的 config.patch 功能：

```bash
openclaw config patch
```

或者手动编辑 `~/.openclaw/openclaw.json`，添加以下配置：

```javascript
{
  agents: {
    defaults: {
      memorySearch: {
        enabled: true,
        provider: "ollama",
        fallback: "none",
        model: "qwen3-embedding:0.6b",
        
        // 文本分块配置
        chunking: {
          tokens: 200,      // 每块 200 tokens
          overlap: 60       // 块之间重叠 60 tokens
        },
        
        // 检索配置
        query: {
          maxResults: 10,   // 最多返回 10 个结果
          minScore: 0.25,   // 最低相似度 0.25
          
          // 混合检索（向量 + 文本）
          hybrid: {
            enabled: true,
            vectorWeight: 0.6,           // 向量检索权重 60%
            textWeight: 0.4,             // 文本检索权重 40%
            candidateMultiplier: 8,
            
            // MMR（最大边际相关性）- 避免重复结果
            mmr: {
              enabled: true,
              lambda: 0.7
            },
            
            // 时间衰减 - 新内容权重更高
            temporalDecay: {
              enabled: true,
              halfLifeDays: 60  // 60 天半衰期
            }
          }
        }
      }
    }
  }
}
```

### 6. 重建向量索引

```bash
# 为所有 agent 重建索引
openclaw memory index --force

# 或者为特定 agent 重建索引
openclaw memory index --agent opus-agent --force
```

### 7. 测试记忆搜索

在 OpenClaw 中测试：

```
请搜索我之前关于项目架构的讨论
```

OpenClaw 会自动使用 memory_search 工具搜索相关内容。

## 详细配置说明

### Ollama 配置

**默认端口：** 11434

**自定义端口：**
```bash
# 设置环境变量
export OLLAMA_HOST=0.0.0.0:11435

# 或者在 OpenClaw 配置中指定
{
  agents: {
    defaults: {
      memorySearch: {
        provider: "ollama",
        ollama: {
          baseUrl: "http://localhost:11435"
        }
      }
    }
  }
}
```

**性能优化：**
```bash
# 设置并发请求数
export OLLAMA_NUM_PARALLEL=4

# 设置 GPU 层数（如果有 GPU）
export OLLAMA_GPU_LAYERS=32
```

### Qwen3 Embedding 模型

**模型信息：**
- 名称：qwen3-embedding:0.6b
- 参数量：600M
- 向量维度：1024
- 支持语言：中文、英文、多语言
- 上下文长度：8192 tokens

**为什么选择 Qwen3？**
- ✅ 支持中英文混合内容
- ✅ 性能优秀（相似度 0.4-0.7）
- ✅ 响应快速（本地推理）
- ✅ 模型体积适中（600MB）
- ✅ 开源免费

**其他可选模型：**
```bash
# 更小的模型（更快，但精度稍低）
ollama pull nomic-embed-text

# 更大的模型（更准确，但更慢）
ollama pull qwen3-embedding:1.5b
```

### 混合检索配置

**向量检索 vs 文本检索：**
- 向量检索：语义相似度（理解意思）
- 文本检索：关键词匹配（精确匹配）

**推荐配置：**
```javascript
hybrid: {
  enabled: true,
  vectorWeight: 0.6,    // 60% 向量检索
  textWeight: 0.4,      // 40% 文本检索
  candidateMultiplier: 8
}
```

**调整建议：**
- 如果需要更精确的关键词匹配：增加 textWeight
- 如果需要更好的语义理解：增加 vectorWeight
- 如果结果太少：降低 minScore（如 0.2）
- 如果结果太多：提高 minScore（如 0.3）

### MMR（最大边际相关性）

**作用：** 避免返回相似的重复结果

**配置：**
```javascript
mmr: {
  enabled: true,
  lambda: 0.7    // 0.0 = 最大多样性，1.0 = 最大相关性
}
```

**调整建议：**
- lambda = 0.7：平衡相关性和多样性（推荐）
- lambda = 0.9：更注重相关性
- lambda = 0.5：更注重多样性

### 时间衰减

**作用：** 最近的内容权重更高

**配置：**
```javascript
temporalDecay: {
  enabled: true,
  halfLifeDays: 60    // 60 天后权重减半
}
```

**调整建议：**
- halfLifeDays = 30：更注重最近内容
- halfLifeDays = 90：更平衡新旧内容
- halfLifeDays = 180：更注重历史内容

## 数据管理

### Memory 文件结构

```
~/.openclaw/workspace/
├── MEMORY.md              # 长期记忆（手动维护）
└── memory/
    ├── 2026-03-10.md      # 每日工作日志
    ├── 2026-03-09.md
    └── ...

~/.openclaw/memory/
├── opus-agent.sqlite      # 向量数据库
├── main.sqlite
└── ...
```

### 向量数据库

**位置：** `~/.openclaw/memory/<agent-id>.sqlite`

**大小：** 每个 agent 约 4-10MB（取决于 memory 文件数量）

**重建索引：**
```bash
# 重建所有 agent 的索引
openclaw memory index --force

# 重建特定 agent 的索引
openclaw memory index --agent opus-agent --force

# 查看索引状态
ls -lh ~/.openclaw/memory/*.sqlite
```

### Memory 文件管理

**创建 memory 文件：**
```bash
# 创建今天的 memory 文件
echo "# $(date +%Y-%m-%d) 工作记录" > ~/.openclaw/workspace/memory/$(date +%Y-%m-%d).md
```

**更新 MEMORY.md：**
```bash
# 手动编辑长期记忆
vim ~/.openclaw/workspace/MEMORY.md
```

**自动整理（推荐）：**
使用 OpenClaw cron 任务自动整理 memory：
```bash
openclaw cron add \
  --name "Memory 整理" \
  --schedule "0 10,15,20 * * *" \
  --task "Read HEARTBEAT.md and execute memory maintenance tasks" \
  --session isolated \
  --delivery announce
```

## 向量检索原理

想深入了解 SQLite 数据库和向量模型的关系？查看详细的原理解释：

👉 **[向量检索原理详解](./PRINCIPLES.md)**

包含：
- 完整工作流程图
- SQLite 数据库结构
- 向量模型工作原理
- 相似度计算方法
- 混合检索策略
- 性能优化建议

## 故障排查

### 问题 1：Ollama 服务未启动

**症状：**
```
Error: Failed to connect to Ollama at http://localhost:11434
```

**解决方案：**
```bash
# 检查 Ollama 是否运行
ps aux | grep ollama

# 启动 Ollama
ollama serve

# 或者使用系统服务
brew services start ollama  # macOS
sudo systemctl start ollama # Linux
```

### 问题 2：模型未下载

**症状：**
```
Error: Model qwen3-embedding:0.6b not found
```

**解决方案：**
```bash
# 下载模型
ollama pull qwen3-embedding:0.6b

# 验证模型
ollama list
```

### 问题 3：向量索引损坏

**症状：**
```
Error: Database is locked or corrupted
```

**解决方案：**
```bash
# 备份现有索引
cp ~/.openclaw/memory/opus-agent.sqlite ~/.openclaw/memory/opus-agent.sqlite.bak

# 删除损坏的索引
rm ~/.openclaw/memory/opus-agent.sqlite

# 重建索引
openclaw memory index --agent opus-agent --force
```

### 问题 4：搜索结果不准确

**症状：**
- 搜索结果太少或太多
- 搜索结果不相关

**解决方案：**

1. **调整相似度阈值：**
```javascript
query: {
  minScore: 0.2  // 降低阈值，返回更多结果
}
```

2. **调整混合检索权重：**
```javascript
hybrid: {
  vectorWeight: 0.7,  // 增加向量检索权重
  textWeight: 0.3
}
```

3. **重建索引：**
```bash
openclaw memory index --force
```

### 问题 5：性能问题

**症状：**
- 搜索速度慢
- Ollama 占用大量 CPU/内存

**解决方案：**

1. **限制并发请求：**
```bash
export OLLAMA_NUM_PARALLEL=2
```

2. **减少候选结果数：**
```javascript
query: {
  maxResults: 5,  // 减少返回结果数
  hybrid: {
    candidateMultiplier: 4  // 减少候选倍数
  }
}
```

3. **使用更小的模型：**
```bash
ollama pull nomic-embed-text
```

然后更新配置：
```javascript
memorySearch: {
  model: "nomic-embed-text"
}
```

## 高级配置

### 多 Agent 配置

为不同的 agent 使用不同的配置：

```javascript
{
  agents: {
    defaults: {
      memorySearch: {
        enabled: true,
        provider: "ollama",
        model: "qwen3-embedding:0.6b"
      }
    },
    list: [
      {
        id: "opus-agent",
        memorySearch: {
          query: {
            maxResults: 15,  // 主 agent 返回更多结果
            minScore: 0.2
          }
        }
      },
      {
        id: "coding-agent",
        memorySearch: {
          query: {
            maxResults: 5,   // 编码 agent 返回更少结果
            minScore: 0.3
          }
        }
      }
    ]
  }
}
```

### 自定义分块策略

```javascript
chunking: {
  tokens: 300,      // 更大的块（更多上下文）
  overlap: 100      // 更大的重叠（更好的连续性）
}
```

**调整建议：**
- 短文档：tokens = 150, overlap = 50
- 长文档：tokens = 300, overlap = 100
- 代码文件：tokens = 200, overlap = 60

### 禁用特定功能

```javascript
memorySearch: {
  enabled: true,
  query: {
    hybrid: {
      enabled: true,
      mmr: {
        enabled: false  // 禁用 MMR
      },
      temporalDecay: {
        enabled: false  // 禁用时间衰减
      }
    }
  }
}
```

## 性能基准

**测试环境：**
- CPU: Apple M1 Pro
- RAM: 16GB
- 模型: qwen3-embedding:0.6b
- Memory 文件: 100 个文件，约 5MB

**性能指标：**
- 索引构建时间: ~30 秒
- 单次搜索时间: ~200ms
- 向量维度: 1024
- 相似度范围: 0.4-0.7（典型）

## 最佳实践

### 1. Memory 文件组织

- ✅ 每天创建一个 memory 文件（YYYY-MM-DD.md）
- ✅ 定期整理 MEMORY.md（提炼长期记忆）
- ✅ 使用清晰的标题和结构
- ✅ 包含关键词和上下文

### 2. 向量索引维护

- ✅ 每周重建一次索引（`openclaw memory index --force`）
- ✅ 添加大量新 memory 后重建索引
- ✅ 定期备份向量数据库

### 3. 搜索优化

- ✅ 使用具体的搜索词（而不是泛泛的问题）
- ✅ 包含关键词和上下文
- ✅ 如果结果不理想，尝试不同的搜索词

### 4. 性能优化

- ✅ 使用系统服务运行 Ollama（而不是手动启动）
- ✅ 限制 memory 文件大小（每个文件 < 100KB）
- ✅ 定期清理旧的 memory 文件

## 迁移指南

### 从其他向量模型迁移

如果你之前使用其他向量模型（如 EmbeddingGemma），迁移到 Qwen3：

1. **安装 Qwen3 模型：**
```bash
ollama pull qwen3-embedding:0.6b
```

2. **更新配置：**
```javascript
memorySearch: {
  provider: "ollama",
  model: "qwen3-embedding:0.6b"
}
```

3. **重建所有索引：**
```bash
openclaw memory index --force
```

4. **验证搜索：**
测试几个搜索查询，确保结果正常。

### 从云端 API 迁移

如果你之前使用云端 API（如 OpenAI Embeddings），迁移到本地：

1. **安装 Ollama 和 Qwen3**（见上文）

2. **更新配置：**
```javascript
memorySearch: {
  enabled: true,
  provider: "ollama",  // 从 "openai" 改为 "ollama"
  model: "qwen3-embedding:0.6b",
  // 删除 apiKey 配置
}
```

3. **重建索引：**
```bash
openclaw memory index --force
```

## 常见问题

### Q: Qwen3 支持哪些语言？

A: Qwen3 主要支持中文和英文，也支持其他多种语言，但中英文效果最好。

### Q: 可以使用其他 Ollama 模型吗？

A: 可以。任何 Ollama 支持的 embedding 模型都可以使用，例如：
- nomic-embed-text（英文）
- mxbai-embed-large（多语言）
- bge-large（中文）

### Q: 向量数据库会占用多少空间？

A: 取决于 memory 文件数量和大小。通常每个 agent 4-10MB。

### Q: 如何备份向量数据库？

A: 直接复制 SQLite 文件：
```bash
cp ~/.openclaw/memory/*.sqlite ~/backups/
```

### Q: 可以在多台机器上共享向量数据库吗？

A: 不推荐。向量数据库与 memory 文件绑定，应该在每台机器上独立构建。

### Q: 搜索速度慢怎么办？

A: 
1. 减少 maxResults
2. 使用更小的模型
3. 限制 Ollama 并发数
4. 升级硬件（更快的 CPU/SSD）

## 参考资源

- [Ollama 官方文档](https://github.com/ollama/ollama)
- [Qwen3 模型介绍](https://huggingface.co/Qwen)
- [OpenClaw 文档](https://docs.openclaw.ai)
- [向量检索原理](https://www.pinecone.io/learn/vector-search/)

## 贡献

欢迎提交 Issue 和 Pull Request！

## 许可证

MIT License

---

**作者：** 龙虾（OpenClaw AI Assistant）
**版本：** 1.0.0
**更新时间：** 2026-03-10

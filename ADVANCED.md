# 进阶方案：memory-lancedb-pro

本文档介绍如何使用 **memory-lancedb-pro** 插件，这是一个增强版的记忆系统，提供了更强大的功能和更好的性能。

## 📋 方案对比

| 功能 | 基础方案（memory-core） | 进阶方案（memory-lancedb-pro） |
|------|------------------------|-------------------------------|
| 向量检索 | ✅ 支持 | ✅ 支持 |
| 混合检索（向量+BM25） | ❌ 不支持 | ✅ 支持 |
| 交叉编码器重排序 | ❌ 不支持 | ✅ 支持 |
| 自动捕获 | ❌ 手动 | ✅ 自动 |
| 自动召回 | ❌ 手动 | ✅ 自动 |
| 智能提取 | ❌ 不支持 | ✅ 支持 |
| 记忆生命周期管理 | ❌ 不支持 | ✅ 支持 |
| 多作用域隔离 | ❌ 不支持 | ✅ 支持 |
| 记忆反思（Reflection） | ❌ 不支持 | ✅ 支持 |
| 管理工具（CLI） | ⚠️ 基础 | ✅ 完整 |

## 🎯 适用场景

**选择基础方案（memory-core）如果：**
- 你只需要基本的向量检索功能
- 你希望手动控制记忆的存储和召回
- 你的记忆数据量较小（< 1000 条）

**选择进阶方案（memory-lancedb-pro）如果：**
- 你需要更准确的检索结果（混合检索 + 重排序）
- 你希望系统自动捕获和召回重要信息
- 你有多个 agent，需要记忆隔离
- 你需要记忆生命周期管理（自动晋升/衰减）
- 你的记忆数据量较大（> 1000 条）

## 📦 安装步骤

### 前置条件

确保你已经完成了基础方案的配置：
- ✅ Ollama 已安装并运行
- ✅ qwen3-embedding:0.6b 模型已下载
- ✅ OpenClaw 配置中已设置 memorySearch

### 1. 安装 memory-lancedb-pro

```bash
npm i -g memory-lancedb-pro@beta
```

### 2. 使用 OpenClaw 插件安装命令

```bash
openclaw plugins install memory-lancedb-pro@beta
```

这个命令会：
- 下载插件到 `~/.openclaw/extensions/memory-lancedb-pro`
- 安装依赖（包括 apache-arrow、@lancedb/lancedb 等）
- 进行安全检查

### 3. 安装依赖

如果自动安装失败，手动安装依赖：

```bash
cd ~/.openclaw/extensions/memory-lancedb-pro
npm install
```

### 4. 全局安装 apache-arrow（可选，但推荐）

```bash
npm i -g apache-arrow
```

这可以解决某些模块解析问题。

## ⚙️ 配置

### 1. 编辑 OpenClaw 配置文件

打开 `~/.openclaw/openclaw.json`，在 `plugins` 部分添加：

```json
{
  "plugins": {
    "slots": {
      "memory": "memory-lancedb-pro"
    },
    "entries": {
      "memory-lancedb-pro": {
        "enabled": true,
        "config": {
          "embedding": {
            "provider": "openai-compatible",
            "baseURL": "http://localhost:11434/v1",
            "model": "qwen3-embedding:0.6b",
            "apiKey": "ollama",
            "dimensions": 1024
          },
          "autoCapture": true,
          "autoRecall": true
        }
      }
    }
  }
}
```

### 2. 配置说明

#### embedding 配置

- `provider`: 使用 `openai-compatible`（Ollama 兼容 OpenAI API）
- `baseURL`: Ollama 服务地址（默认 `http://localhost:11434/v1`）
- `model`: 向量模型名称（`qwen3-embedding:0.6b`）
- `apiKey`: 任意字符串（Ollama 不需要真实 API key）
- `dimensions`: 向量维度（qwen3-embedding:0.6b 是 1024 维）

#### 功能开关

- `autoCapture`: 自动捕获对话中的重要信息
- `autoRecall`: 自动在需要时召回相关记忆

### 3. 验证配置

```bash
openclaw config validate
```

应该显示：
```
Config valid: ~/.openclaw/openclaw.json
```

### 4. 重启 OpenClaw

```bash
openclaw gateway restart
```

或者使用 OpenClaw 内置命令：
```
/restart
```

## ✅ 验证安装

### 1. 检查插件状态

```bash
openclaw status
```

应该看到：
```
│ Memory          │ enabled (plugin memory-lancedb-pro)                                                               │
```

### 2. 查看插件日志

```bash
openclaw logs --plain | grep memory-lancedb-pro
```

应该看到：
```
[plugins] memory-lancedb-pro@1.1.0-beta.6: plugin registered (db: /Users/xxx/.openclaw/memory/lancedb-pro, model: qwen3-embedding:0.6b)
```

### 3. 测试存储功能

在 OpenClaw 中执行：

```
使用 memory_store 存储一条测试记忆
```

### 4. 测试检索功能

```
使用 memory_recall 搜索刚才存储的记忆
```

应该能看到类似的输出：
```
Found 1 memories:

1. [xxx] [fact:agent:opus-agent] 测试记忆内容... (93%, vector+BM25+reranked)
```

注意 `vector+BM25+reranked` 标记，这表示使用了混合检索和重排序。

## 🔧 高级配置

### 混合检索配置

```json
{
  "config": {
    "embedding": { ... },
    "autoCapture": true,
    "autoRecall": true,
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
```

#### 参数说明

- `vectorWeight`: 向量检索权重（0-1，默认 0.6）
- `textWeight`: 文本检索权重（0-1，默认 0.4）
- `candidateMultiplier`: 候选结果倍数（默认 8，即检索 8 倍的候选结果再重排序）
- `mmr.lambda`: MMR 去重参数（0-1，默认 0.7，越大越多样化）
- `temporalDecay.halfLifeDays`: 时间衰减半衰期（默认 60 天）

### 记忆反思（Reflection）

启用记忆反思功能，让 AI 自动总结和提炼记忆：

```json
{
  "config": {
    "sessionStrategy": "memoryReflection",
    "memoryReflection": {
      "enabled": true,
      "minMessages": 10,
      "maxMessages": 50,
      "reflectionInterval": 20
    }
  }
}
```

### 多作用域配置

为不同的 agent 配置独立的记忆作用域：

```json
{
  "config": {
    "scopes": {
      "default": "agent:opus-agent",
      "definitions": {
        "agent:opus-agent": "主 agent 的记忆",
        "agent:web-dev": "网站开发助理的记忆",
        "agent:product-dept": "产品部助理的记忆"
      },
      "agentAccess": {
        "opus-agent": ["agent:opus-agent", "shared"],
        "web-dev": ["agent:web-dev", "shared"],
        "product-dept": ["agent:product-dept", "shared"]
      }
    }
  }
}
```

## 📊 管理工具

memory-lancedb-pro 提供了完整的 CLI 管理工具：

### 查看记忆统计

```bash
openclaw memory-pro stats
```

### 搜索记忆

```bash
openclaw memory-pro search "关键词"
```

### 列出所有记忆

```bash
openclaw memory-pro list --limit 10
```

### 导出记忆

```bash
openclaw memory-pro export --output memories.json
```

### 导入记忆

```bash
openclaw memory-pro import --input memories.json
```

### 删除记忆

```bash
# 删除单条记忆
openclaw memory-pro delete <memory-id>

# 批量删除
openclaw memory-pro delete-bulk --scope "agent:test" --confirm
```

### 重新生成向量

如果更换了 embedding 模型，需要重新生成向量：

```bash
openclaw memory-pro reembed --confirm
```

## 🔄 从基础方案迁移

如果你之前使用的是基础方案（memory-core），可以这样迁移：

### 1. 备份现有数据

```bash
# 备份 workspace
cd ~/.openclaw/workspace
git add -A
git commit -m "backup: 迁移到 memory-lancedb-pro 前的备份"
git push

# 备份 memory 数据库
cp -r ~/.openclaw/memory ~/.openclaw/memory.backup
```

### 2. 安装 memory-lancedb-pro

按照上面的安装步骤进行。

### 3. 迁移记忆数据

memory-lancedb-pro 会自动检测旧的 memory-core 数据并提示迁移：

```bash
openclaw memory-pro migrate check
```

如果需要迁移：

```bash
openclaw memory-pro migrate run
```

### 4. 验证迁移结果

```bash
openclaw memory-pro migrate verify
```

## 🐛 故障排查

### 问题 1：插件加载失败

**错误信息：**
```
[plugins] memory-lancedb-pro failed during register: Error: Cannot find module 'apache-arrow'
```

**解决方案：**
```bash
# 安装依赖
cd ~/.openclaw/extensions/memory-lancedb-pro
npm install

# 全局安装 apache-arrow
npm i -g apache-arrow

# 重启 OpenClaw
openclaw gateway restart
```

### 问题 2：向量维度错误

**错误信息：**
```
Unsupported embedding model: qwen3-embedding:0.6b. Either add it to EMBEDDING_DIMENSIONS or set embedding.dimensions in config.
```

**解决方案：**

在配置中添加 `dimensions: 1024`：

```json
{
  "embedding": {
    "provider": "openai-compatible",
    "baseURL": "http://localhost:11434/v1",
    "model": "qwen3-embedding:0.6b",
    "apiKey": "ollama",
    "dimensions": 1024
  }
}
```

### 问题 3：Ollama 连接失败

**错误信息：**
```
Failed to connect to Ollama at http://localhost:11434
```

**解决方案：**

```bash
# 检查 Ollama 是否运行
ollama list

# 如果没有运行，启动它
ollama serve

# 或者使用系统服务
brew services start ollama  # macOS
sudo systemctl start ollama  # Linux
```

### 问题 4：检索结果不准确

**可能原因：**
- 向量权重配置不合理
- 候选结果数量太少
- 时间衰减参数不合适

**解决方案：**

调整混合检索参数：

```json
{
  "hybrid": {
    "vectorWeight": 0.7,  // 增加向量权重
    "textWeight": 0.3,
    "candidateMultiplier": 12  // 增加候选结果数量
  }
}
```

## 📈 性能优化

### 1. 定期清理过期记忆

```bash
# 删除 90 天前的记忆
openclaw memory-pro delete-bulk --before "2025-12-01" --confirm
```

### 2. 优化向量数据库

```bash
# 重新生成向量（优化索引）
openclaw memory-pro reembed --confirm
```

### 3. 调整缓存大小

在配置中添加：

```json
{
  "config": {
    "cache": {
      "enabled": true,
      "maxSize": 1000,
      "ttl": 3600
    }
  }
}
```

## 🎓 最佳实践

### 1. 记忆分类

使用不同的 category 来组织记忆：

- `preference`: 用户偏好
- `fact`: 事实信息
- `decision`: 决策记录
- `entity`: 实体信息（人、项目等）
- `reflection`: 反思和总结

### 2. 重要性评分

合理设置 importance（0-1）：

- `0.9-1.0`: 核心偏好、关键决策
- `0.7-0.9`: 重要事实、常用信息
- `0.5-0.7`: 一般信息
- `0.3-0.5`: 临时信息
- `0.0-0.3`: 不重要的信息

### 3. 作用域管理

为不同的 agent 使用独立的作用域：

```javascript
// opus-agent 的记忆
memory_store({
  scope: "agent:opus-agent",
  text: "...",
  category: "preference"
})

// web-dev 的记忆
memory_store({
  scope: "agent:web-dev",
  text: "...",
  category: "fact"
})
```

### 4. 定期维护

建议每月执行一次：

```bash
# 1. 查看统计信息
openclaw memory-pro stats

# 2. 导出备份
openclaw memory-pro export --output backup-$(date +%Y%m%d).json

# 3. 清理过期记忆
openclaw memory-pro delete-bulk --before "90 days ago" --confirm

# 4. 优化数据库
openclaw memory-pro reembed --confirm
```

## 🔗 参考资源

- [memory-lancedb-pro GitHub](https://github.com/openclaw/memory-lancedb-pro)
- [LanceDB 文档](https://lancedb.github.io/lancedb/)
- [Ollama 文档](https://ollama.com/docs)
- [Qwen3 模型](https://huggingface.co/Qwen/Qwen3-0.6B-Base)
- [OpenClaw 文档](https://docs.openclaw.ai)

## 📝 更新日志

### 2026-03-11
- 初始版本
- 完整的安装和配置指南
- 故障排查和最佳实践

---

**需要帮助？** 在 [OpenClaw Discord](https://discord.com/invite/clawd) 提问或查看 [GitHub Issues](https://github.com/openclaw/openclaw/issues)。

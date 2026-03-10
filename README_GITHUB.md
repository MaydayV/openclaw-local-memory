# OpenClaw Local Memory Setup

完整的 OpenClaw 本地记忆系统配置指南 - 使用 Ollama + Qwen3 Embedding 实现完全本地化的语义搜索。

## 特性

- ✅ 完全本地化（无需 API key）
- ✅ 支持中英文混合内容
- ✅ 混合检索（向量 + 文本）
- ✅ 时间衰减（最近内容权重更高）
- ✅ MMR 去重（避免重复结果）
- ✅ 高性能（响应快速）

## 快速开始

### 一键安装

```bash
curl -fsSL https://raw.githubusercontent.com/MaydayV/openclaw-local-memory/main/install.sh | bash
```

### 手动安装

1. **安装 Ollama:**
   ```bash
   # macOS
   brew install ollama
   
   # Linux
   curl -fsSL https://ollama.com/install.sh | sh
   ```

2. **下载 Qwen3 模型:**
   ```bash
   ollama pull qwen3-embedding:0.6b
   ```

3. **配置 OpenClaw:**
   ```bash
   # 使用示例配置
   cp config-example.json ~/.openclaw/openclaw-memory-patch.json
   openclaw config patch < ~/.openclaw/openclaw-memory-patch.json
   ```

4. **重建索引:**
   ```bash
   openclaw memory index --force
   ```

## 文档

- [完整文档](./README.md) - 详细的配置和使用指南
- [快速开始](./QUICKSTART.md) - 5 分钟快速配置
- [配置示例](./config-example.json) - OpenClaw 配置示例
- [安装脚本](./install.sh) - 自动化安装脚本

## 系统要求

- macOS / Linux / Windows
- 至少 4GB 可用内存
- 至少 2GB 可用磁盘空间
- OpenClaw 2026.3.2 或更高版本

## 性能基准

- 索引构建时间: ~30 秒（100 个文件）
- 单次搜索时间: ~200ms
- 向量维度: 1024
- 模型大小: 600MB

## 故障排查

### Ollama 服务未启动

```bash
# macOS
brew services start ollama

# Linux
sudo systemctl start ollama
```

### 搜索结果不准确

调整相似度阈值：
```json
{
  "query": {
    "minScore": 0.2
  }
}
```

更多问题请查看[完整文档](./README.md#故障排查)。

## 贡献

欢迎提交 Issue 和 Pull Request！

## 许可证

MIT License

## 作者

龙虾（OpenClaw AI Assistant）

## 更新日志

- 2026-03-10: 初始版本
  - 完整的安装和配置指南
  - 自动化安装脚本
  - 故障排查和最佳实践
  - 性能优化建议

---

**需要帮助？** 查看[完整文档](./README.md)或访问 [OpenClaw 官方文档](https://docs.openclaw.ai)

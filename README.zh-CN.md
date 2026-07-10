# grok-memory-stack

为已使用 Claude Code 全局设定（`~/.claude/CLAUDE.md` + rules）与 vault/qmd 的环境，提供 **Grok Build CLI** 薄记忆适配。

- **热层**：Grok 原生 `~/.grok/memory/`
- **宪法**：Claude 文件（compat 加载，不复制全文）
- **冷库**：vault + qmd（跨 AI 共享）

## 安装

```bash
git clone https://github.com/yang1997434/grok-memory-stack.git
cd grok-memory-stack
./install.sh
```

## 验证

```bash
bash scripts/e2e-verify.sh
```

详见 [README.md](README.md) 与 [docs/architecture.md](docs/architecture.md)。

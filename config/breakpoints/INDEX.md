# Grok project breakpoints (Claude save 兼容层)

Claude `/save` 写入 `~/.claude/projects/<cwd-encoded>/memory/session_latest.md`。  
Grok 侧镜像到本目录，便于新 session 无缝读断点（不依赖 Claude auto-memory 加载）。

| key | cwd 提示 | 来源 |
|-----|----------|------|
| data-claude | /data/Claude | vault/global + 本会话记忆栈 |
| sub2api | /data/Claude/sub2api | -data-Claude-sub2api |
| keleclaw-api | /data/Claude/keleclaw-api | -data-Claude-api-openclaw |
| la-work | /data/Claude/la-work | -data-Claude-la-work |
| tavern | /data/Claude/tavern | -data-Claude-tavern |
| feishu | (飞书 bot 相关 cwd) | -data-Claude-feishu |
| flowalpha | wiki/outline | -data-Claude-wiki |

## Schema (与 Claude save 对齐)

```markdown
---
name: Session breakpoint
description: YYYY-MM-DD — headline
type: project
date: YYYY-MM-DD
projects: [key, ...]
---

## Done this session
## Open items
## Blockers
## Rollback markers
```

## 协议

- 进入项目目录 **新开** Grok session 时: Read 对应 `breakpoints/<key>/session_latest.md`。
- **Resume** 同 session: 以对话历史为准,断点作补充。
- 收工更新: 写回本文件(固定四节),勿只改 Claude 侧 unless 双写。
- 机密不进断点正文;密钥见 `~/.flow/credentials.local` / `~/.flow/keys/`。

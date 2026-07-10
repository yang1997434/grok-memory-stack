#!/usr/bin/env python3
"""Scaffold a vault _LLM_Memory/global entry + optional index line."""
from __future__ import annotations

import argparse
import os
import re
import sys
from datetime import datetime
from pathlib import Path

TYPES = ("feedback", "pitfall", "pattern", "claude", "infra", "user")


def slugify(title: str) -> str:
    s = title.strip().lower()
    s = re.sub(r"[^\w\u4e00-\u9fff]+", "_", s, flags=re.UNICODE)
    s = re.sub(r"_+", "_", s).strip("_")
    return s[:80] or "entry"


def insert_index_line(mem_path: Path, type_name: str, index_line: str, eid: str) -> None:
    text = mem_path.read_text(encoding="utf-8")
    if eid in text or index_line in text:
        print(f"index already mentions {eid}; left MEMORY.md unchanged")
        return

    lines = text.splitlines(keepends=True)
    out: list[str] = []
    inserted = False
    i = 0
    while i < len(lines):
        out.append(lines[i])
        if (
            not inserted
            and lines[i].startswith("## ")
            and type_name in lines[i].lower()
        ):
            # optional existing blank after header
            if i + 1 < len(lines) and lines[i + 1].strip() == "":
                i += 1
                out.append(lines[i])
            out.append(index_line + "\n")
            inserted = True
        i += 1

    if not inserted:
        out.append(f"\n## {type_name}\n\n{index_line}\n")

    mem_path.write_text("".join(out), encoding="utf-8")
    print(f"indexed in {mem_path}")


def main() -> int:
    ap = argparse.ArgumentParser(description=__doc__)
    ap.add_argument("--type", required=True, choices=TYPES)
    ap.add_argument("--title", required=True, help="name / short title")
    ap.add_argument("--description", required=True, help="one-line retrieval hook")
    ap.add_argument("--id", default="", help="filename id")
    ap.add_argument("--body-file", default="", help="markdown body without frontmatter")
    ap.add_argument("--body", default="", help="inline body text")
    ap.add_argument("--vault", default="", help="vault root")
    ap.add_argument(
        "--status",
        default="active",
        choices=("draft", "candidate", "active", "validated", "archived"),
    )
    ap.add_argument("--author", default="grok")
    ap.add_argument("--no-index", action="store_true")
    ap.add_argument("--dry-run", action="store_true")
    args = ap.parse_args()

    vault = Path(
        args.vault
        or os.environ.get("VAULT_PATH", "")
        or Path.home() / "data" / "knowledge-base"
    ).expanduser()
    global_dir = vault / "_LLM_Memory" / "global"
    type_dir = global_dir / args.type
    if not global_dir.is_dir():
        print(f"ERROR: vault global memory missing: {global_dir}", file=sys.stderr)
        return 2

    base = slugify(args.title)
    eid = args.id or f"{args.type}_{base}"
    path = type_dir / f"{eid}.md"
    type_dir.mkdir(parents=True, exist_ok=True)

    body = args.body
    if args.body_file:
        body = Path(args.body_file).read_text(encoding="utf-8")
    if not body.strip():
        body = "(promoted from Grok memory)\n\n## Related\n\n- \n"

    now = datetime.now().astimezone()
    created = now.strftime("%Y-%m-%d")
    modified = now.strftime("%Y-%m-%dT%H:%M:%S")

    extra = ""
    if args.type == "pitfall":
        extra = """trigger:
  keywords: []
  tools: []
checklist:
  - "TODO: fill checklist"
remedy: "TODO: fill remedy"
"""

    fm = f"""---
id: {eid}
name: {args.title}
description: {args.description}
type: {args.type}
status: {args.status}
created: '{created}'
last_modified_at: '{modified}'
last_modified_by: {args.author}
{extra}---
{body.rstrip()}
"""

    index_line = f"- [{args.title}]({args.type}/{eid}.md) — {args.description}"
    if len(index_line) > 150:
        index_line = index_line[:147] + "..."

    if args.dry_run:
        print("=== would write ===")
        print(path)
        print(fm)
        print("=== index line ===")
        print(index_line)
        return 0

    if path.exists():
        print(f"ERROR: exists (update manually): {path}", file=sys.stderr)
        return 3

    path.write_text(fm + "\n", encoding="utf-8")
    print(f"wrote {path}")

    if not args.no_index:
        mem = global_dir / "MEMORY.md"
        if mem.is_file():
            insert_index_line(mem, args.type, index_line, eid)
        else:
            print(f"WARN: no {mem}; skip index", file=sys.stderr)

    print("NEXT: pointerize ~/.grok/memory/MEMORY.md ; qmd update if needed")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())

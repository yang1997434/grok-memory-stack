#!/usr/bin/env bash
# Grok memory-stack E2E — isolated canary tests, prints PASS/FAIL, exit 1 on any fail.
set -euo pipefail

CANARY_ID="e2e-canary-$(date +%s)-$$"
CANARY_LINE="- [E2E] ${CANARY_ID} — disposable test marker, safe to delete"
ROOT_MEM="${HOME}/.grok/memory/MEMORY.md"
BACKUP_MEM="${HOME}/.grok/memory/MEMORY.md.bak-e2e-$$"
REPORT="/tmp/grok-memory-e2e/report-${CANARY_ID}.txt"
WORKDIR="/tmp/grok-memory-e2e/work"
PASS=0
FAIL=0
SKIP=0

mkdir -p /tmp/grok-memory-e2e "$WORKDIR"
: >"$REPORT"

log() { echo "$*" | tee -a "$REPORT"; }
pass() { PASS=$((PASS+1)); log "PASS  $1"; }
fail() { FAIL=$((FAIL+1)); log "FAIL  $1"; }
skip() { SKIP=$((SKIP+1)); log "SKIP  $1"; }

cleanup_canary() {
  if [[ -f "$BACKUP_MEM" ]]; then
    mv -f "$BACKUP_MEM" "$ROOT_MEM"
  elif [[ -f "$ROOT_MEM" ]]; then
    # remove only our canary line if backup missing
    grep -vF "$CANARY_ID" "$ROOT_MEM" >"${ROOT_MEM}.tmp" 2>/dev/null || true
    mv -f "${ROOT_MEM}.tmp" "$ROOT_MEM" 2>/dev/null || true
  fi
  # remove any workspace memory dirs created under our temp workdir sessions
  # (session files under ~/.grok/sessions for workdir — cleaned later)
  rm -rf "${HOME}/.grok/memory/"*e2e* 2>/dev/null || true
}

trap 'cleanup_canary' EXIT

log "=== Grok memory E2E ${CANARY_ID} ==="
log "time: $(date -Iseconds)"

# --- T1: config parse ---
if python3 - <<'PY'
import tomllib
from pathlib import Path
c=tomllib.load(Path.home().joinpath(".grok/config.toml").open("rb"))
assert c["memory"]["enabled"] is True
assert c["memory"]["session"]["save_on_end"] is False
assert c["memory"]["dream"]["enabled"] is False
assert c["memory"]["initial_injection"]["min_score"] == 0.35
assert c["compaction"]["memory_flush"]["enabled"] is False
assert c["compat"]["claude"]["hooks"] is False
assert c["compat"]["claude"]["agents"] is True
print("ok")
PY
then pass "T1 config.toml memory/compat nested keys"
else fail "T1 config.toml parse/assert"
fi

# --- T2: files exist ---
if [[ -f "$HOME/.grok/AGENTS.md" ]] && grep -q 'grok-memory-stack:start' "$HOME/.grok/AGENTS.md"; then
  pass "T2 AGENTS.md managed block present"
else
  fail "T2 AGENTS.md missing or no managed block"
fi
if [[ -f "$ROOT_MEM" ]] && grep -q 'Self-instructions' "$ROOT_MEM"; then
  pass "T2 MEMORY.md skeleton present"
else
  fail "T2 MEMORY.md skeleton missing"
fi

# --- T3: inspect three cwds ---
inspect_one() {
  local cwd="$1" label="$2"
  local out="/tmp/grok-memory-e2e/inspect-${label}.json"
  (cd "$cwd" && grok inspect --json >"$out" 2>/dev/null) || { fail "T3 inspect failed for $label"; return; }
  python3 - "$out" "$label" <<'PY'
import json,sys
from pathlib import Path
p,label=sys.argv[1],sys.argv[2]
d=json.loads(Path(p).read_text())
paths=[x.get("path","") for x in d.get("projectInstructions") or []]
agents_ok=any(p.endswith("/.grok/AGENTS.md") for p in paths)
claude_ok=any(p.endswith("/.claude/CLAUDE.md") for p in paths)
hooks=d.get("hooks") or []
claude_hooks=[h for h in hooks if h.get("vendor")=="claude"]
claude_all_dis=all(h.get("disabled") for h in claude_hooks) if claude_hooks else True
cells=(d.get("externalCompat") or {}).get("cells") or []
hooks_cell=next((c for c in cells if c.get("vendor")=="claude" and c.get("surface")=="hooks"), None)
hooks_off=hooks_cell and hooks_cell.get("enabled") is False
print(json.dumps({
  "label": label,
  "agents_ok": agents_ok,
  "claude_ok": claude_ok,
  "claude_hooks": len(claude_hooks),
  "claude_all_disabled": claude_all_dis,
  "hooks_cell_off": bool(hooks_off),
  "paths": paths,
}, ensure_ascii=False))
if not agents_ok: sys.exit(2)
if not claude_ok: sys.exit(3)
if claude_hooks and not claude_all_dis: sys.exit(4)
if not hooks_off: sys.exit(5)
PY
}

for pair in "/data/Claude:root" "/data/Claude/sub2api:sub2api" "/data/Claude/keleclaw-api:keleclaw"; do
  cwd="${pair%%:*}"; label="${pair##*:}"
  if inspect_one "$cwd" "$label"; then
    pass "T3 inspect $label: AGENTS+CLAUDE loaded, claude hooks disabled"
  else
    fail "T3 inspect $label assertions"
  fi
done

# --- T4: inject canary into MEMORY.md and verify memory_search via headless ---
cp -a "$ROOT_MEM" "$BACKUP_MEM"
printf '\n%s\n' "$CANARY_LINE" >>"$ROOT_MEM"
# give watcher a moment
sleep 1

# Headless session in isolated workdir (path-based workspace bucket)
mkdir -p "$WORKDIR"
OUT1="/tmp/grok-memory-e2e/headless-search.txt"
set +e
(
  cd "$WORKDIR"
  # config already has memory enabled; still pass experimental for clarity
  grok --experimental-memory --always-approve --permission-mode bypassPermissions \
    --max-turns 8 \
    -p "You have memory tools. Search memory for the exact string '${CANARY_ID}'. If found, reply with a single line: FOUND ${CANARY_ID}. If not found after searching, reply: NOTFOUND ${CANARY_ID}. No other text." \
    >"$OUT1" 2>/tmp/grok-memory-e2e/headless-search.err
)
rc=$?
set -e
log "headless search rc=$rc"
if grep -q "FOUND ${CANARY_ID}" "$OUT1" 2>/dev/null; then
  pass "T4 headless memory_search found canary"
elif grep -qi "NOTFOUND\|not found\|no memory" "$OUT1" 2>/dev/null; then
  fail "T4 memory_search did not find canary (see $OUT1)"
  log "--- stdout ---"; tail -30 "$OUT1" | tee -a "$REPORT"
  log "--- stderr ---"; tail -20 /tmp/grok-memory-e2e/headless-search.err | tee -a "$REPORT"
else
  # ambiguous
  if [[ $rc -eq 0 ]] && grep -q "$CANARY_ID" "$OUT1" 2>/dev/null; then
    pass "T4 headless mentioned canary (soft)"
  else
    fail "T4 headless search unclear rc=$rc"
    tail -40 "$OUT1" 2>/dev/null | tee -a "$REPORT" || true
    tail -20 /tmp/grok-memory-e2e/headless-search.err 2>/dev/null | tee -a "$REPORT" || true
  fi
fi

# --- T5: --no-memory still runs (smoke) ---
OUT2="/tmp/grok-memory-e2e/headless-nomem.txt"
set +e
(
  cd "$WORKDIR"
  grok --no-memory --always-approve --max-turns 2 \
    -p "Reply with exactly: NOMEM_OK" >"$OUT2" 2>/tmp/grok-memory-e2e/headless-nomem.err
)
rc2=$?
set -e
if grep -q "NOMEM_OK" "$OUT2" 2>/dev/null; then
  pass "T5 --no-memory headless smoke"
else
  fail "T5 --no-memory smoke failed rc=$rc2"
  tail -20 "$OUT2" /tmp/grok-memory-e2e/headless-nomem.err 2>/dev/null | tee -a "$REPORT" || true
fi

# --- T6: qmd vault cold path still works ---
if command -v qmd >/dev/null; then
  if qmd --index kb-yp search "memory" -c kb -n 2 >/tmp/grok-memory-e2e/qmd.out 2>/tmp/grok-memory-e2e/qmd.err; then
    if [[ -s /tmp/grok-memory-e2e/qmd.out ]]; then
      pass "T6 qmd kb-yp search works"
    else
      fail "T6 qmd returned empty"
    fi
  else
    fail "T6 qmd search error"
    cat /tmp/grok-memory-e2e/qmd.err | tee -a "$REPORT" || true
  fi
else
  skip "T6 qmd not installed"
fi

# --- T7: keleclaw same-origin bucket note (static) ---
o1=$(git -C /data/Claude/keleclaw-api remote get-url origin 2>/dev/null || true)
o2=$(git -C /data/Claude/keleclaw-api-marketing remote get-url origin 2>/dev/null || true)
if [[ -n "$o1" && "$o1" == "$o2" ]]; then
  pass "T7 keleclaw-api and marketing share origin (documented product-family bucket)"
  log "     origin=$o1"
else
  skip "T7 origins differ or missing o1=$o1 o2=$o2"
fi

# --- T8: pager.toml prompt bg ---
if [[ -f "$HOME/.grok/pager.toml" ]] && grep -q 'bg = "dark"' "$HOME/.grok/pager.toml"; then
  pass "T8 pager.toml prompt bg=dark"
else
  fail "T8 pager.toml missing or bg not dark"
fi

# cleanup canary before summary (trap also runs)
cleanup_canary
trap - EXIT

# remove e2e sessions created under workdir encoding if any (best-effort)
# list sessions groups matching work
find "$HOME/.grok/sessions" -maxdepth 1 -type d -name '*grok-memory-e2e*' 2>/dev/null | while read -r d; do
  log "removing session group $d"
  rm -rf "$d"
done
# also URL-encoded /tmp/grok-memory-e2e/work
find "$HOME/.grok/sessions" -maxdepth 1 -type d 2>/dev/null | while read -r d; do
  if [[ -f "$d/.cwd" ]] && grep -q 'grok-memory-e2e' "$d/.cwd" 2>/dev/null; then
    log "removing session group by .cwd $d"
    rm -rf "$d"
  fi
done

# workspace memory for temp path
find "$HOME/.grok/memory" -maxdepth 1 -type d 2>/dev/null | while read -r d; do
  base=$(basename "$d")
  [[ "$base" == "." || "$base" == ".." ]] && continue
  # leave global MEMORY.md parent
  if [[ -f "$d/MEMORY.md" ]] && grep -qE 'e2e-canary|grok-memory-e2e' "$d/MEMORY.md" 2>/dev/null; then
    log "note: workspace memory may contain e2e: $d"
  fi
done

log ""
log "=== SUMMARY PASS=$PASS FAIL=$FAIL SKIP=$SKIP ==="
log "report: $REPORT"
if [[ "$FAIL" -gt 0 ]]; then
  exit 1
fi
exit 0

#!/usr/bin/env bash
# self-check.sh — "is the system ready?" check for the parallel-ai-dev kit.
#
# Run from the ROOT of your repository:
#     bash <path>/parallel-ai-dev/scripts/self-check.sh          # normative R1–R9
#     bash <path>/parallel-ai-dev/scripts/self-check.sh --full   # + extended diagnostics
#
# The script changes and deletes nothing — it only reads and prints.
#
# TWO LAYERS:
#   1) NORMATIVE checks R1–R9 — determine the exit code. ONLY violations
#      are printed (green stays quiet: the on-screen list is your checklist, not noise).
#   2) EXTENDED diagnostics (file freshness, PR discipline, junction hazards…) —
#      advice, not a verdict. Shown with --full or when the project has
#      coordination/.selfcheck.conf. STRICT_ADVISORY=1 in that config also makes
#      red results in this layer fatal (for teams wanting stricter checks).
#
# Exit code: 0 — R1–R9 clean (✅ SYSTEM READY); 1 — violations exist.
# The "no silent failures" rule applies to this script too.
#
# Compatibility: bash 3.2 (macOS) — no mapfile, no associative arrays.

set -uo pipefail

KIT_ROOT="${KIT_HOME:-$HOME}/parallel-ai-dev"
KIT_VER="?"
[ -f "$KIT_ROOT/VERSION" ] && KIT_VER="$(head -1 "$KIT_ROOT/VERSION" | tr -d '\r ')"

FULL=0
[ "${1:-}" = "--full" ] && FULL=1

# ─────────────────────────────────────────────────────────────── prerequisites ───
if ! git rev-parse --is-inside-work-tree >/dev/null 2>&1; then
  echo "🔴 This is not a git repository. The kit requires git: memory outside git does not exist."
  echo "   Fix: git init && git add -A && git commit -m 'initial'"
  echo "❌ REMAINING: 1"
  exit 1
fi
cd "$(git rev-parse --show-toplevel)" || exit 1

HAS_HEAD=1
git rev-parse -q --verify HEAD >/dev/null 2>&1 || HAS_HEAD=0

# ── memory file paths: default layout, overridable in .selfcheck.conf ──
# Projects rarely follow the template layout exactly. A check that complains
# about a healthy state teaches people to ignore red — so both normative R checks
# and diagnostics read the same config:
#     DECISIONS=docs/DECISIONS.md
#     PROJECT_MAP=coordination/PRODUCT_MAP.md
#     WORKSTREAMS=../_HQ/WORKSTREAMS.md      # may also be outside the repo
DECISIONS=coordination/DECISIONS.md
MISTAKES=coordination/MISTAKES.md
PROJECT_MAP=coordination/PROJECT_MAP.md
BACKLOG=coordination/BACKLOG.md
WORKSTREAMS=coordination/WORKSTREAMS.md
STRICT_ADVISORY=0

CONF=coordination/.selfcheck.conf
HAS_CONF=0
if [ -f "$CONF" ]; then
  HAS_CONF=1
  # shellcheck disable=SC1090
  . "$CONF"
fi

# ── SETUP.md: three declarations (visibility / mode / constitution) ──────────────
SETUP=coordination/SETUP.md
VISIBILITY=""; MODE=""; CONSTITUTION="kit"
setup_val() { # $1 = key; prints the first word after "key:"
  sed -n "s/^[[:space:]]*$1:[[:space:]]*//p" "$SETUP" 2>/dev/null \
    | head -1 | awk '{print $1}' | tr -d '\r'
}
if [ -f "$SETUP" ]; then
  VISIBILITY="$(setup_val visibility)"
  MODE="$(setup_val mode)"
  C="$(setup_val constitution)"; [ -n "$C" ] && CONSTITUTION="$C"
fi

# ── helpers ────────────────────────────────────────────────────────────────
in_repo() { case "$1" in /*|../*) return 1 ;; *) return 0 ;; esac; }
strip_noise() { # removes HTML comments and fenced code blocks — template examples
  # Remove SINGLE-LINE comments FIRST (s///): the sed range /<!--/,/-->/
  # does NOT close on the same line where it opens — otherwise a single-line
  # comment consumes the rest of the file and live entries "disappear" (caught by T3).
  sed 's/<!--.*-->//' "$1" 2>/dev/null | sed '/<!--/,/-->/d' | sed '/^```/,/^```/d'
}

NFAIL=0
FAILS=""
rfail() { # $1 = "R2", $2 = message
  NFAIL=$((NFAIL+1))
  FAILS="${FAILS}${1} 🔴 ${2}"$'\n'
}

# ─────────────────────────────────────────────────────────── report header ─────
echo
echo "parallel-ai-dev kit self-check (kit v$KIT_VER)"
echo "Project: $(basename "$(pwd)")"
echo "Date:    $(date '+%Y-%m-%d %H:%M')"
# "Fresh installation?" — if memory has never been committed, the red lines
# below are a step-by-step plan, not a reprimand. Say so explicitly: a beginner
# who just installed everything and immediately sees six 🔴 may think they broke it.
if [ "$HAS_HEAD" = 0 ] || ! git log -1 --format=%H -- coordination/ >/dev/null 2>&1 \
   || [ -z "$(git log -1 --format=%H -- coordination/ 2>/dev/null)" ]; then
  echo
  echo "This is expected at this stage: the system was just installed — the lines below are"
  echo "your startup checklist, not a list of failures."
fi
echo

# ════════════════════════════════════ NORMATIVE CHECKS R1–R9 ═════════════

# R1 — required files exist (paths come from config, if present)
R1_MISS=""
for f in CLAUDE.md "$DECISIONS" "$MISTAKES" "$PROJECT_MAP" "$BACKLOG" "$WORKSTREAMS"; do
  [ -e "$f" ] || R1_MISS="$R1_MISS $f"
done
if [ "$CONSTITUTION" = "kit" ] && [ ! -e CLAUDE.parallel-ai-dev.md ]; then
  R1_MISS="$R1_MISS CLAUDE.parallel-ai-dev.md"
fi
[ -n "$R1_MISS" ] && rfail R1 "missing files:$R1_MISS — run bash $KIT_ROOT/scripts/init-memory.sh"

# R2 — memory files are TRACKED by git (untracked = unprotected)
if [ "$HAS_HEAD" = 0 ]; then
  rfail R2 "the repository has no commits yet — create the first: git add -A && git commit -m 'initial'"
else
  R2_MISS=""
  for f in CLAUDE.md "$DECISIONS" "$MISTAKES" "$PROJECT_MAP" "$BACKLOG" "$WORKSTREAMS" "$SETUP"; do
    [ -e "$f" ] || continue
    in_repo "$f" || continue   # file intentionally outside this repo (config) — git here cannot judge it
    git ls-files --error-unmatch "$f" >/dev/null 2>&1 \
      || R2_MISS="$R2_MISS $f"
  done
  [ -e CLAUDE.parallel-ai-dev.md ] && ! git ls-files --error-unmatch CLAUDE.parallel-ai-dev.md >/dev/null 2>&1 \
    && R2_MISS="$R2_MISS CLAUDE.parallel-ai-dev.md"
  [ -n "$R2_MISS" ] && rfail R2 "not committed (untracked):$R2_MISS — git add + commit + push, otherwise memory will not survive disk cleanup"
  # NEW memory files must also be protected: an inbox message or note that
  # was created but not committed is the most common student data-loss case
  # (AC-16; the canonical list above misses it, git diff does not show untracked files).
  R2_NEW=$(git ls-files --others --exclude-standard -- coordination/ 2>/dev/null | grep -c . || true)
  [ "${R2_NEW:-0}" -gt 0 ] && rfail R2 "$R2_NEW new files in coordination/ are not committed — git add + commit + push (git status shows which ones)"
fi

# R3 — TRACKED memory files have no uncommitted edits
# (untracked belongs to R2; here we catch "edited and forgot to commit")
if [ "$HAS_HEAD" = 1 ]; then
  R3_PATHS="coordination CLAUDE.md"
  [ -e CLAUDE.parallel-ai-dev.md ] && R3_PATHS="$R3_PATHS CLAUDE.parallel-ai-dev.md"
  for f in "$DECISIONS" "$PROJECT_MAP" "$BACKLOG" "$MISTAKES" "$WORKSTREAMS"; do
    in_repo "$f" && case "$f" in coordination/*) : ;; *) R3_PATHS="$R3_PATHS $f" ;; esac
  done
  # shellcheck disable=SC2086
  R3_N=$( { git diff --name-only -- $R3_PATHS; git diff --cached --name-only -- $R3_PATHS; } 2>/dev/null | sort -u | grep -c . || true)
  [ "${R3_N:-0}" -gt 0 ] && rfail R3 "$R3_N memory files have uncommitted edits — commit and push (git status shows which ones)"
fi

# R4 — memory files are not hidden by .gitignore
# --no-index is required: without it check-ignore is SILENT about an already tracked
# file covered by an ignore rule (empirically verified, review 2.0.1) — and that state
# hides all FUTURE files alongside it.
R4_BAD=""
for f in CLAUDE.md "$DECISIONS" "$MISTAKES" "$PROJECT_MAP" "$BACKLOG" "$WORKSTREAMS" "$SETUP"; do
  in_repo "$f" || continue
  git check-ignore --no-index -q "$f" 2>/dev/null && R4_BAD="$R4_BAD $f"
done
[ -n "$R4_BAD" ] && rfail R4 "gitignore hides memory files:$R4_BAD — remove these paths from .gitignore"

# R5 — constitution is connected
if [ "$CONSTITUTION" = "self-managed" ]; then
  # The project declared its OWN constitution: check that it exists and refers
  # to the cross-check files, rather than an import (otherwise loop prevention has no basis).
  if [ ! -e CLAUDE.md ]; then
    rfail R5 "constitution: self-managed, but CLAUDE.md is missing — your own constitution must exist"
  else
    R5_MISS=""
    for f in "$DECISIONS" "$PROJECT_MAP" "$BACKLOG"; do
      k=$(basename "$f" .md)
      grep -q "$k" CLAUDE.md 2>/dev/null || R5_MISS="$R5_MISS $k"
    done
    [ -n "$R5_MISS" ] && rfail R5 "your own constitution does not mention cross-check files:$R5_MISS — the chat will not know where to check before a task"
  fi
else
  if [ ! -e CLAUDE.md ]; then
    rfail R5 "CLAUDE.md is missing — no chat can see the constitution; run the kit installer"
  elif ! grep -q '^@CLAUDE\.parallel-ai-dev\.md' CLAUDE.md 2>/dev/null; then
    rfail R5 "CLAUDE.md does not connect the kit rules — add as the FIRST line after the heading: @CLAUDE.parallel-ai-dev.md"
  fi
fi

# R6 — project map is filled in (not an empty template)
if [ -e "$PROJECT_MAP" ]; then
  # Two conditions: (a) the file DIFFERS from the kit's pristine template (compare without
  # \r — Windows line endings must not fake "filled in"); (b) it has at least one
  # meaningful line. Measure content by "any non-whitespace character", NOT
  # [[:alnum:]]: in git-bash's C locale Cyrillic is not alnum, so a Ukrainian-only
  # map was counted as empty (caught by test T3).
  R6_TPL="$KIT_ROOT/template/coordination/PROJECT_MAP.md"
  # Lines matching pristine template lines verbatim (table header, etc.) are
  # not content: otherwise a "header + separator" file counted as filled in
  # (AC-17, caught by review 2.0.1). grep -Fxv -f filters out exactly those lines.
  if [ -f "$R6_TPL" ]; then
    R6_N=$(strip_noise "$PROJECT_MAP" | tr -d '\r' | grep -v '^#' | grep -v '^[[:space:]]*>' \
           | grep -v '^[[:space:]]*|[-: |]*$' | grep '[^[:space:]]' \
           | grep -Fxv -f <(tr -d '\r' < "$R6_TPL") | grep -c . || true)
  else
    R6_N=$(strip_noise "$PROJECT_MAP" | grep -v '^#' | grep -v '^[[:space:]]*>' \
           | grep -v '^[[:space:]]*|[-: |]*$' | grep -c '[^[:space:]]' || true)
  fi
  R6_EMPTY=0
  if [ -f "$R6_TPL" ] && cmp -s <(tr -d '\r' < "$PROJECT_MAP") <(tr -d '\r' < "$R6_TPL"); then
    R6_EMPTY=1   # pristine template, byte for byte
  fi
  { [ "$R6_EMPTY" = 1 ] || [ "${R6_N:-0}" -lt 1 ]; } \
    && rfail R6 "$(basename "$PROJECT_MAP") is empty — describe what ALREADY exists in the project (this seeds loop prevention: without a map, chats rebuild existing work)"
fi

# R7 — decisions contain at least one entry
if [ -e "$DECISIONS" ]; then
  # Count entry headings AFTER removing examples: the template contains the entry
  # format in a fenced block and a dated example in an HTML comment — neither
  # must count, or an empty template reports "entries exist".
  R7_N=$(strip_noise "$DECISIONS" | grep -c '^## ' || true)
  [ "${R7_N:-0}" -lt 1 ] && rfail R7 "$(basename "$DECISIONS") has no entries — add 3-5 ALREADY made decisions with a 'Why' field (a decision without a reason does not prevent rebuilding)"
fi

# R8 — SETUP.md contains valid values
if [ ! -f "$SETUP" ]; then
  rfail R8 "coordination/SETUP.md is missing — three declarations (visibility/mode/constitution) are required; run the kit installer"
else
  case "$VISIBILITY" in
    private|public-accepted) : ;;
    *) rfail R8 "SETUP.md visibility must be: private or public-accepted" ;;
  esac
  case "$MODE" in
    team|solo) : ;;
    *) rfail R8 "SETUP.md mode must be: team or solo" ;;
  esac
  case "$CONSTITUTION" in
    kit|self-managed) : ;;
    *) rfail R8 "SETUP.md constitution must be: kit or self-managed" ;;
  esac
fi

# R9 — team mode requires worktree isolation
# mode not declared yet → treat as team: requiring isolation is safer than
# silently skipping its check.
if [ "$MODE" != "solo" ]; then
  WT_N=$(git worktree list 2>/dev/null | grep -c . || true)
  if [ "${WT_N:-1}" -lt 2 ]; then
    rfail R9 "parallel chats lack isolation — create a worktree: git worktree add ../$(basename "$(pwd)")-chat2 -b chat2 (or declare mode: solo)"
  fi
fi

# ─────────────────────────────────────────────── normative layer verdict ───
if [ "$NFAIL" -eq 0 ]; then
  echo "Checked R1…R9: no violations."
else
  printf '%s' "$FAILS"
fi
echo

# ════════════════════════════════ EXTENDED DIAGNOSTICS (advice, not a verdict) ═══
ADV_SHOWN=0
ADV_FAIL=0
if [ "$FULL" = 1 ] || [ "$HAS_CONF" = 1 ]; then
  ADV_SHOWN=1
  PASS=0; WARN=0; FAIL=0
  ROWS=""
  row() { # <status> <rule> <evidence>
    local s="$1" r="$2" e="$3"
    case "$s" in
      ok)   PASS=$((PASS+1)); s="🟢 yes" ;;
      warn) WARN=$((WARN+1)); s="🟡 partial" ;;
      bad)  FAIL=$((FAIL+1)); s="🔴 no" ;;
      skip) s="⚪ n/a" ;;
    esac
    # The separator is a tab, not "|": evidence often contains "|", which breaks
    # the table. This is not hypothetical — it broke the very first run.
    e="${e//$'\t'/ }"
    ROWS+="$s"$'\t'"$r"$'\t'"$e"$'\n'
  }
  have() { git ls-files --error-unmatch "$1" >/dev/null 2>&1; }

  echo "── Extended diagnostics (does not affect the R1–R9 verdict$( [ "$STRICT_ADVISORY" = 1 ] && echo '; STRICT_ADVISORY=1 — does affect it' )) ──"
  echo

  # 1. foundation
  if git remote | grep -q .; then
    row ok "Remote exists (push as backup)" "$(git remote | head -1)"
  else
    row bad "Remote exists (push as backup)" "git remote is empty — only the local disk protects this work"
  fi

  if [ -e CLAUDE.md ]; then
    L=$(wc -l < CLAUDE.md | tr -d ' ')
    if [ "$L" -gt 400 ]; then
      row warn "CLAUDE.md is not bloated" "$L lines — it is in EVERY session's context; move lengthy material to reference files"
    else
      row ok "CLAUDE.md is not bloated" "$L lines"
    fi
  fi

  # Do NOT search for arbitrary <…>: a healthy CLAUDE.md has legitimate <path>, <PR#>
  # tokens in command examples. Match only the kit template's placeholder lines.
  # (Our own run produced 19 "violations", all false. Hence the rewrite.)
  PH_TOKENS='<НАЗВА>|<перелічи шляхи|<напр\. |<\.\.\.>'
  # Beware: `grep -c` with no matches prints "0" ITSELF and exits 1 —
  # a fallback `echo 0` would append a second line. Use `|| true` instead.
  PH=$(grep -cE "$PH_TOKENS" CLAUDE.md 2>/dev/null || true)
  if [ "${PH:-0}" -gt 0 ]; then
    row bad "CLAUDE.md template placeholders filled" "$PH placeholder lines remain — risk areas or check/deploy commands are not filled in"
  else
    row ok "CLAUDE.md template placeholders filled" "no unfilled placeholders found"
  fi

  # 2. memory file freshness
  for f in "$DECISIONS" "$MISTAKES" "$PROJECT_MAP" "$BACKLOG" "$WORKSTREAMS"; do
    n=$(basename "$f")
    if have "$f" || [ -f "$f" ]; then
      TS=$(git log -1 --format=%at -- "$f" 2>/dev/null)
      if [ -n "$TS" ]; then
        LAST=$(git log -1 --format=%ad --date=short -- "$f")
        SRC="last commit"
        NOCOMMIT=0
      else
        # A commit may be absent for two DIFFERENT reasons; do not confuse them: the file
        # was just created and is uncommitted (warning), or it lives in another
        # repository (our WORKSTREAMS case — inspect the disk then).
        TS=$(date -r "$f" +%s 2>/dev/null || echo 0)
        LAST=$(date -r "$f" '+%Y-%m-%d' 2>/dev/null || echo "unknown")
        NOCOMMIT=1
        case "$f" in
          /*|../*) SRC="modified on disk (file outside this repository)"; NOCOMMIT=0 ;;
          *)       SRC="created $LAST, but NOT YET COMMITTED" ;;
        esac
      fi
      AGE_D=$(( ( $(date +%s) - TS ) / 86400 ))
      if [ "$NOCOMMIT" = 1 ]; then
        row warn "$n is active" "$SRC — commit it, otherwise the file is unprotected"
      elif [ "$AGE_D" -gt 30 ]; then
        row warn "$n is active" "$SRC $LAST — over 30 days ago; the file exists but is inactive"
      else
        row ok "$n is active" "$SRC $LAST"
      fi
    else
      row bad "$n exists" "file is missing"
    fi
  done

  # Entry quality: "Why" in decisions, "Rule" in mistakes
  if [ -f "$DECISIONS" ]; then
    H=$(strip_noise "$DECISIONS" | grep -c '^## ' || true)
    W=$(strip_noise "$DECISIONS" | grep -c '^\*\*Чому' || true)
    if [ "${H:-0}" -gt 0 ] && [ "${W:-0}" -lt "$H" ]; then
      row warn "Every decision has a 'Why'" "$H entries, $W 'Why' fields"
    elif [ "${H:-0}" -gt 0 ]; then
      row ok "Every decision has a 'Why'" "$H entries, $W 'Why' fields"
    fi
  fi
  if [ -f "$MISTAKES" ]; then
    H=$(strip_noise "$MISTAKES" | grep -c '^## ' || true)
    R=$(strip_noise "$MISTAKES" | grep -c 'Правило на майбутнє' || true)
    if [ "${H:-0}" -gt 0 ] && [ "${R:-0}" -lt "$H" ]; then
      row warn "Every mistake has a rule" "$H entries, $R rules — an entry without a rule is a diary, not a safeguard"
    elif [ "${H:-0}" -gt 0 ]; then
      row ok "Every mistake has a rule" "$H entries, $R rules"
    fi
  fi

  # 4. coordination
  # README.md inside the inbox is instructions, not a message: without excluding it,
  # a freshly installed kit's empty inbox reports "1 message".
  IN=$(git ls-files 'coordination/inbox/*' 2>/dev/null | grep -vi '/readme\.md$' | grep -c . || true)
  if [ "${IN:-0}" -eq 0 ]; then
    row warn "Inbox is used" "0 messages in git — either only one chat exists, or correspondence bypasses git"
  else
    OKN=$(git ls-files 'coordination/inbox/*' | grep -vi '/readme\.md$' | grep -c 'from-.*-to-' || true)
    row ok "Inbox is used" "$IN messages, $OKN matching from-*-to-*"
  fi

  DEL=$(git log --diff-filter=D --name-only --format= -- coordination/inbox/ 2>/dev/null | grep -c 'coordination/inbox/' || true)
  if [ "${DEL:-0}" -gt 0 ]; then
    row bad "Processed messages are not deleted" "$DEL deletions found — the inbox is a journal; do not clear it"
  else
    row ok "Processed messages are not deleted" "no deletions in history"
  fi

  if [ -f "$WORKSTREAMS" ]; then
    # Count ONLY table rows: [COORD] legitimately appears in rule text and in a
    # commented-out example too — otherwise a fresh template reports "two coordinators".
    WS_ROWS=$(strip_noise "$WORKSTREAMS" | grep '^[[:space:]]*|' | grep '\[COORD\]' || true)
    C=$(printf '%s' "$WS_ROWS" | grep -c . || true)
    TODAY=$(date '+%Y-%m-%d')
    if [ "${C:-0}" -eq 0 ]; then
      row warn "Exactly one coordinator dated today" "no [COORD] rows — the role is unclaimed"
    elif [ "$C" -gt 1 ]; then
      row bad "Exactly one coordinator" "$C [COORD] rows — two coordinators collide on the same PR"
    elif printf '%s' "$WS_ROWS" | grep -q "$TODAY"; then
      row ok "Exactly one coordinator dated today" "[COORD] row is dated $TODAY"
    else
      row warn "Coordinator date is current" "[COORD] row exists, but is not dated today — the role is available"
    fi
  fi

  # 5. discipline
  U=$(git status --porcelain 2>/dev/null | wc -l | tr -d ' ')
  if [ "$U" -gt 0 ]; then
    row warn "No uncommitted changes" "$U dirty files — an untracked file is an unprotected file"
  else
    row ok "No uncommitted changes" "working tree is clean"
  fi

  UP=$(git log --oneline @{u}..HEAD 2>/dev/null | wc -l | tr -d ' ')
  if [ "${UP:-0}" -gt 0 ]; then
    row warn "Everything is pushed" "$UP unpushed commits — pushing is the backup"
  else
    row ok "Everything is pushed" "no local unpushed commits"
  fi

  MAIN=$(git symbolic-ref --short refs/remotes/origin/HEAD 2>/dev/null | sed 's|origin/||')
  MAIN=${MAIN:-main}
  TOT=$(git log --first-parent "origin/$MAIN" --format='%s' -40 2>/dev/null | wc -l | tr -d ' ')
  VIAPR=$(git log --first-parent "origin/$MAIN" --format='%s' -40 2>/dev/null | grep -c '(#[0-9]' || true)
  if [ "${TOT:-0}" -gt 0 ]; then
    if [ "$VIAPR" -lt $(( TOT * 8 / 10 )) ]; then
      row warn "Delivery through PRs, not direct commits" "$VIAPR of the last $TOT commits came through PRs"
    else
      row ok "Delivery through PRs, not direct commits" "$VIAPR of the last $TOT commits came through PRs"
    fi
  fi

  # 6. gates: swallowed exit codes
  # \b around names is required: without it "tsconfig.json" matches "tsc" and
  # the script reports a violation where none exists.
  GATE_RE='\b(tsc|eslint|vitest|jest|pytest|next build)\b[^|&]*(\|[[:space:]]*(tail|head)|\|\|[[:space:]]*true)'
  SW_LINES=$(grep -rnE "$GATE_RE" \
       --include='*.sh' --include='*.yml' --include='*.yaml' --include='package.json' . 2>/dev/null \
       | grep -v '^\./\.git/' | grep -vE '^[^:]+:[0-9]+:[[:space:]]*#')
  SW=$(printf '%s' "$SW_LINES" | grep -c . || true)
  if [ "${SW:-0}" -gt 0 ]; then
    FIRST=$(printf '%s' "$SW_LINES" | head -1 | cut -c1-60)
    row bad "Gate exit codes are not swallowed" "$SW locations, e.g. $FIRST — the gate is disabled but appears enabled"
  else
    row ok "Gate exit codes are not swallowed" "no tail/head/true constructs found near gates"
  fi

  # 7. worktrees and junction hazards
  WT=$(git worktree list 2>/dev/null | wc -l | tr -d ' ')
  MINES=0; MINELIST=""
  while read -r d _; do
    [ -z "$d" ] && continue
    for nm in "$d/node_modules" "$d/vendor" "$d/.venv"; do
      if [ -L "$nm" ]; then MINES=$((MINES+1)); MINELIST="$MINELIST\n      $nm -> $(readlink "$nm" 2>/dev/null)"; fi
    done
  done < <(git worktree list 2>/dev/null | awk '{print $1}')

  # ⚠️ Honest limitation: git-bash on Windows does NOT recognize every NTFS junction
  # as a link (in our repo bash counted 19 hazards, PowerShell — 39).
  # The Windows count below is a LOWER bound; the definitive answer comes from
  # the PowerShell command printed at the end.
  IS_WIN=0
  case "$(uname -s 2>/dev/null)" in MINGW*|MSYS*|CYGWIN*) IS_WIN=1 ;; esac

  if [ "$WT" -gt 20 ]; then
    row warn "Worktrees do not accumulate" "$WT worktrees — clean up completed ones: git worktree remove <path>"
  else
    row ok "Worktrees do not accumulate" "$WT worktrees"
  fi

  if [ "$MINES" -gt 0 ]; then
    SUF=""; [ "$IS_WIN" = 1 ] && SUF=" (on Windows this is a LOWER bound; the actual count is higher)"
    row bad "Worktrees have no junction hazards" "$MINES worktrees link to shared dependencies$SUF — recursively deleting such a directory wipes the main project's code"
  elif [ "$IS_WIN" = 1 ]; then
    row warn "Worktrees have no junction hazards" "bash on Windows cannot see every junction — check with the PowerShell command below"
  else
    row ok "Worktrees have no junction hazards" "no links to shared dependencies found in worktrees"
  fi

  # 8. kit version
  if [ -f coordination/.kit-version ]; then
    row ok "Kit version is known" "$(head -1 coordination/.kit-version | cut -c1-12)"
  else
    row warn "Kit version is known" "coordination/.kit-version is missing — freshness check will honestly report 'unknown'"
  fi

  printf '%b' "$ROWS" | awk -F'\t' '
    BEGIN { printf "%-12s  %-44s  %s\n", "STATUS", "RULE", "EVIDENCE";
            printf "%-12s  %-44s  %s\n", "----", "-------", "------------" }
    NF>=3 { printf "%-12s  %-44s  %s\n", $1, $2, $3 }'
  echo
  echo "Diagnostics: 🟢 $PASS   🟡 $WARN   🔴 $FAIL"
  if [ -n "$MINELIST" ]; then
    echo
    echo "  ⚠️  Worktrees that MUST NOT be deleted as ordinary folders:"
    printf '%b\n' "$MINELIST"
    echo "      Clean up only with: git worktree remove <path>"
  fi
  if [ "$IS_WIN" = 1 ]; then
    echo
    echo "  Windows: only PowerShell gives the complete list of hazards (bash misses some junctions) —"
    echo "  git worktree list | ForEach-Object { (\$_ -split '\\s+')[0] } | ForEach-Object {"
    echo "    \$n = Join-Path \$_ 'node_modules'"
    echo "    if (Test-Path \$n) { \$i = Get-Item \$n -Force; if (\$i.LinkType) { \"\$n -> \$(\$i.Target)\" } } }"
  fi
  echo
  ADV_FAIL=$FAIL
fi

# ═══════════════════════════════════════════════════ final verdict ═════
if [ "$NFAIL" -eq 0 ] && { [ "$STRICT_ADVISORY" != 1 ] || [ "$ADV_FAIL" -eq 0 ]; }; then
  echo "✅ SYSTEM READY"
  exit 0
fi
if [ "$NFAIL" -eq 0 ] && [ "$STRICT_ADVISORY" = 1 ] && [ "$ADV_FAIL" -gt 0 ]; then
  echo "R1–R9 are clean, but STRICT_ADVISORY=1 and diagnostics have $ADV_FAIL 🔴 — fix them."
  echo "❌ REMAINING: $ADV_FAIL"
  exit 1
fi
echo "❌ REMAINING: $NFAIL"
exit 1

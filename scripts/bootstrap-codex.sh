#!/usr/bin/env bash
# Adapted from ymaxymovych/tz-skills: Codex, four project skills, no deletion.
# bootstrap-codex.sh — preserve and check the installed English Codex kit.
#
#   cd /path/to/your/project
#   bash scripts/bootstrap-codex.sh
# Output is always English.
#
# Components (existing project files are preserved):
#   1. parallel-ai-dev (project memory)          → upstream templates in $KIT_HOME (default ~), English memory in the project
#   2. tz-skills (/tz-draft /tz-review /tz-verify /tz-go) → copy into $CODEX_SKILLS_DIR (default .agents/skills)
#   3. providers.json: Codex + optional NVIDIA NIM slots, preserve existing config
#   4. IMMUNE — 7 rules against code rot           → stored in the project's AGENTS.md
#   5. Checks: memory self-check + critics smoke test → honest table AS IS
#
# Exit code: 0 — all green; 1 — red rows exist (the "what to do" list is printed).
# Red does NOT mean broken — it is the checklist of what a human / Codex still has to do.
#
# Overrides (tests and non-standard folders):
#   KIT_LANG is retained only for backward-compatible invocations; output is English.
#   KIT_HOME=…            where to clone parallel-ai-dev            (default $HOME)
#   CODEX_SKILLS_DIR=…   where to install the skills                (default $PWD/.agents/skills)
#   TZ_PROVIDERS_CONFIG=… where providers.json lives                 (default $PWD/providers.json)

set -u
set -o pipefail

TZ_ROOT="${TZ_KIT_ROOT:-$HOME/tz-skills}"
ADAPTER_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
KIT_HOME="${KIT_HOME:-$HOME}"
SKILLS_DIR="${CODEX_SKILLS_DIR:-$PWD/.agents/skills}"
PROVIDERS="${TZ_PROVIDERS_CONFIG:-$PWD/providers.json}"
PROJECT_DIR="$(pwd)"
PAD_REPO="https://github.com/ymaxymovych/parallel-ai-dev.git"

# Format an English message without evaluating it as shell code.
L() { printf '%s' "$1"; }
say()  { printf '%s\n' "$*"; }
hr()   { say "────────────────────────────────────────────────────────"; }

ROWS=()
TODO=()
RED=0
ok()   { ROWS+=("✅ $1"); }
bad()  { ROWS+=("🔴 $1"); TODO+=("$2"); RED=1; }
info() { ROWS+=("ℹ️  $1"); }

hr; say "$(L 'Student kit — one-shot installation')"
say "$(L 'Project'): $PROJECT_DIR"; hr

# ── 1. Prerequisites ──────────────────────────────────────────────────────────
say "1/7 $(L 'Prerequisites')"
have() { command -v "$1" >/dev/null 2>&1; }
for t in git curl; do
  if have "$t"; then say "   ✓ $t"; else
    say "   ✗ $t $(L 'NOT found')"
    bad "$t $(L 'is missing')" "$(L "Install $t and run the script again")"; fi
done
if have python3 || have python || have jq; then say "   ✓ python $(L 'or') jq"; else
  say "   ✗ $(L 'neither python nor jq')"
  bad "$(L 'python/jq missing')" "$(L 'Install python3 (python.org) or jq — needed for the API-based critics')"; fi
if have codex; then say "   ✓ codex (Codex CLI)"; else
  say "   ⚠ codex $(L 'not on PATH')"
  bad "$(L 'Codex CLI not on PATH')" "$(L 'Skills will install, but the codex-cli critic cannot run: make sure Codex is installed and the codex command works in this terminal')"; fi

# ── 2. Project = git repo, run from its root ──────────────────────────────────
say "2/7 $(L 'Project git repository')"
if ! git rev-parse --is-inside-work-tree >/dev/null 2>&1; then
  git init -q && say "   ✓ $(L 'created a new git repository (there was none here)')" \
    || bad "$(L 'git init failed')" "$(L "Check the project folder: $PROJECT_DIR")"
fi
if [ -n "$(git rev-parse --show-prefix 2>/dev/null)" ]; then
  say "   ✗ $(L 'this is a SUBFOLDER of the repository, not its root'): $(git rev-parse --show-toplevel)"
  bad "$(L 'Script was run outside the repository root')" "cd $(git rev-parse --show-toplevel) && bash scripts/bootstrap-codex.sh"
  say ""; say "$(L 'Stopping: memory placed in a subfolder is invisible to every chat.')"; exit 1
fi
if [ -z "$(git config user.email 2>/dev/null)" ]; then
  bad "$(L 'git does not know your email')" "$(L 'git config --global user.email "you@example.com" (and user.name) — commits do not work without it')"
else
  say "   ✓ git user.email: $(git config user.email)"
fi

# ── 3. parallel-ai-dev (project memory) ───────────────────────────────────────
say "3/7 $(L 'Project-memory kit (parallel-ai-dev)')"
PAD_DIR=""
for d in "$KIT_HOME/parallel-ai-dev" "$PROJECT_DIR/../parallel-ai-dev" "$PROJECT_DIR/../../parallel-ai-dev"; do
  if [ -d "$d/.git" ]; then PAD_DIR="$(cd "$d" && pwd)"; break; fi
done
if [ -n "$PAD_DIR" ]; then
  say "   • found: $PAD_DIR — using existing checkout without updating it"
else
  PAD_DIR="$KIT_HOME/parallel-ai-dev"
  if git clone -q "$PAD_REPO" "$PAD_DIR" 2>/dev/null; then say "   ✓ $(L 'cloned into') $PAD_DIR"; else
    bad "$(L 'Could not clone parallel-ai-dev')" "$(L "Check the network and run: git clone $PAD_REPO $PAD_DIR")"; PAD_DIR=""; fi
fi
# This repository contains the translated memory files. Do not recreate
# Ukrainian templates over a missing project file; report what needs restoring.
MEMORY_READY=1
for memory_file in CLAUDE.md coordination/SETUP.md coordination/PROJECT_MAP.md coordination/DECISIONS.md coordination/MISTAKES.md coordination/BACKLOG.md coordination/WORKSTREAMS.md; do
  if [ ! -s "$PROJECT_DIR/$memory_file" ]; then
    bad "Missing project memory: $memory_file" "Restore the English file from this repository's history"
    MEMORY_READY=0
  fi
done
[ "$MEMORY_READY" -eq 1 ] && ok "English project memory present"

# ── 4. Skills /tz-* ──────────────────────────────────────────────────────────
say "4/7 $(L 'Codex skills') → $SKILLS_DIR"
mkdir -p "$SKILLS_DIR"
INSTALLED=0
for s in tz-draft tz-review tz-verify tz-go; do
  src="$PROJECT_DIR/.agents/skills/$s"; dst="$SKILLS_DIR/$s"
  if [ -s "$dst/SKILL.md" ]; then
    say "   ✓ /$s (existing project version preserved)"; INSTALLED=$((INSTALLED+1))
  elif [ -e "$dst" ]; then
    say "   ✗ /$s is incomplete; preserved for manual review"
  elif [ -d "$src" ] && cp -R "$src" "$dst"; then
    say "   ✓ /$s"; INSTALLED=$((INSTALLED+1))
  else
    say "   ✗ /$s missing; restore the English skill from this repository"
  fi
done
if [ "$INSTALLED" -eq 4 ]; then ok "$(L '4 skills /tz-draft /tz-review /tz-verify /tz-go installed')"; else
  bad "$(L "Installed $INSTALLED/4 skills")" "$(L "Restore the missing English skills from this repository; do not overwrite local translations with upstream copies")"; fi

# ── 5. Critics: providers.json + NVIDIA key ──────────────────────────────────
say "5/7 $(L 'Critics') (providers.json → $PROVIDERS)"
mkdir -p "$(dirname "$PROVIDERS")"

# Keep provider choices stable. Configure optional hosted models explicitly.
if [ ! -f "$PROVIDERS" ]; then
  cat > "$PROVIDERS" <<'JSON'
{
  "_comment": "Codex plus two optional NVIDIA-hosted critics. Credentials come from environment variables. Model availability must be verified before full review. Existing configuration is never replaced by bootstrap.",
  "critics": {
    "critic_a": { "backend": "codex-cli" },
    "critic_b": { "backend": "nim", "model": "minimaxai/minimax-m3", "api_key_env": "NVIDIA_API_KEY" },
    "critic_c": { "backend": "nim", "model": "nvidia/nemotron-3.5-lightning-30b-a3b", "api_key_env": "NVIDIA_API_KEY" }
  }
}
JSON
  ok "providers.json created; optional hosted models require live verification"
else
  ok "providers.json already existed — kept yours"
fi
if [ -z "${NVIDIA_API_KEY:-}" ]; then
  if grep -qs 'NVIDIA_API_KEY' "$HOME/.bashrc" 2>/dev/null; then
    info "$(L 'NVIDIA_API_KEY is in ~/.bashrc but not in this terminal — it will be picked up after a terminal restart')"
  fi
  bad "No NVIDIA_API_KEY — two of the three course critics cannot run" "HUMAN: open https://build.nvidia.com (sign in with Google, no card needed), then https://build.nvidia.com/settings/api-keys → Generate API Key. Paste the nvapi-… key to Codex; it must be stored in user-level secret storage and never committed or printed. Base drafting and local Codex work remain available meanwhile."
else
  say "   ✓ NVIDIA_API_KEY $(L 'present in the environment')"
fi

# ── 6. IMMUNE in the project's AGENTS.md ──────────────────────────────────────
say "6/7 IMMUNE — $(L 'rules against code rot') → AGENTS.md"
BLOCK="$TZ_ROOT/docs/IMMUNE_CLAUDE_BLOCK.en.md"
if [ -f "$PROJECT_DIR/AGENTS.md" ] && grep -qE 'Rules against code rot \(IMMUNE\)' "$PROJECT_DIR/AGENTS.md"; then
  say "   • $(L 'block already present — not duplicating')"; ok "$(L 'IMMUNE already in AGENTS.md')"
elif [ ! -f "$BLOCK" ]; then
  bad "$(L "File $BLOCK not found")" "$(L "Update tz-skills: git -C $TZ_ROOT pull --ff-only")"
else
  { printf '\n'; cat "$BLOCK"; } >> "$PROJECT_DIR/AGENTS.md" && { say "   ✓ $(L 'appended to the end of AGENTS.md')"; ok "$(L 'IMMUNE appended to AGENTS.md')"; } \
    || bad "$(L 'Could not append IMMUNE')" "$(L "Copy the contents of $BLOCK to the end of $PROJECT_DIR/AGENTS.md by hand")"
fi

# ── 7. Checks (commits are deliberate, separate actions) ─────────────────────
say "7/7 Checks"
say "   • $(L 'memory self-check') $(L '(English output)'):"
if [ -n "$PAD_DIR" ]; then
  if (cd "$PROJECT_DIR" && bash "$ADAPTER_DIR/memory-self-check.sh" 2>&1 | sed 's/^/     /'); then
    ok "self-check: ✅ $(L 'SYSTEM READY')"
  else
    bad "$(L 'memory self-check has red rows (expected on a fresh system)')" "$(L "CODEX: fill in coordination/SETUP.md (visibility, mode), coordination/PROJECT_MAP.md (what already exists in the project), coordination/DECISIONS.md (3-5 decisions with a 'Why' field), the project-zones section of AGENTS.md; commit and push; rerun bash scripts/check-setup.sh")"
  fi
fi

say "   • $(L 'critics smoke test'):"
if [ -z "${NVIDIA_API_KEY:-}" ]; then
  if TZ_PROVIDERS_CONFIG="$PROVIDERS" bash "$ADAPTER_DIR/llm-critic.sh" --smoke critic_a 2>&1 | sed 's/^/     /'; then
    ok "Codex critic responds"
  else
    bad "Codex critic failed" "Run bash scripts/llm-critic.sh --smoke critic_a and resolve the reported error"
  fi
  info "Base setup is usable, but full course readiness requires the two NVIDIA-hosted critic slots"
else
  if TZ_PROVIDERS_CONFIG="$PROVIDERS" bash "$ADAPTER_DIR/llm-critic.sh" --smoke-all 2>&1 | sed 's/^/     /'; then
    ok "Critics: all 3 slots respond"
  else
    bad "Critics: not all 3 slots respond" "Run bash scripts/llm-critic.sh --smoke-all and resolve the reported errors"
  fi
fi

# ── Summary ───────────────────────────────────────────────────────────────────
hr; say "$(L 'SUMMARY')"; hr
for r in "${ROWS[@]}"; do say "$r"; done
if [ "$RED" -eq 1 ]; then
  hr; say "$(L 'WHAT TO DO (one item at a time, top to bottom):')"
  i=1; for t in "${TODO[@]}"; do say "$i. $t"; i=$((i+1)); done
  hr; say "$(L 'Red is not a failure — it is a checklist. When everything is done, run the script again: existing skill folders are preserved.')"
  exit 1
fi
hr; say "✅ $(L 'Required setup checks passed. Commands'): /tz-go ($(L 'everything on its own')) · /tz-draft · /tz-review · /tz-verify"
exit 0

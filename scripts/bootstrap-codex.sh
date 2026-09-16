#!/usr/bin/env bash
# Adapted from ymaxymovych/tz-skills: Codex, four project skills, no deletion.
# bootstrap-student.sh — «одна команда» / "one command": розгортає ВЕСЬ студентський комплект.
#
#   cd /path/to/your/project
#   bash ~/tz-skills/lib/bootstrap-student.sh              # Ukrainian output (default)
#   KIT_LANG=en bash ~/tz-skills/lib/bootstrap-student.sh  # English output + English IMMUNE block
#
# Що ставить / What it installs (ідемпотентно — можна запускати повторно, нічого твого не перезаписує):
#   1. parallel-ai-dev (project memory)          → clone into $KIT_HOME (default ~), init-memory in the project
#   2. tz-skills (/tz-draft /tz-review /tz-verify /tz-go) → copy into $CODEX_SKILLS_DIR (default .agents/skills)
#   3. providers.json: Codex + optional NVIDIA NIM slots, preserve existing config
#   4. IMMUNE — 7 rules against code rot           → stored in the project's AGENTS.md
#   5. Checks: memory self-check + critics smoke test → honest table AS IS
#
# Exit code: 0 — all green; 1 — red rows exist (the "what to do" list is printed).
# Red does NOT mean broken — it is the checklist of what a human / Codex still has to do.
#
# Overrides (tests and non-standard folders):
#   KIT_LANG=uk|en        language of this script's output and of the IMMUNE block (default uk)
#   KIT_HOME=…            where to clone parallel-ai-dev            (default $HOME)
#   CODEX_SKILLS_DIR=…   where to install the skills                (default $PWD/.agents/skills)
#   TZ_PROVIDERS_CONFIG=… where providers.json lives                 (default $PWD/providers.json)

set -u
set -o pipefail

TZ_ROOT="${TZ_KIT_ROOT:-$HOME/tz-skills}"
ADAPTER_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
KIT_LANG="${KIT_LANG:-en}"
KIT_HOME="${KIT_HOME:-$HOME}"
SKILLS_DIR="${CODEX_SKILLS_DIR:-$PWD/.agents/skills}"
PROVIDERS="${TZ_PROVIDERS_CONFIG:-$PWD/providers.json}"
PROJECT_DIR="$(pwd)"
PAD_REPO="https://github.com/ymaxymovych/parallel-ai-dev.git"

# L "ukrainian" "english" → prints the string for the active language.
L() { if [ "$KIT_LANG" = "en" ]; then printf '%s' "$2"; else printf '%s' "$1"; fi; }
say()  { printf '%s\n' "$*"; }
hr()   { say "────────────────────────────────────────────────────────"; }

ROWS=()
TODO=()
RED=0
ok()   { ROWS+=("✅ $1"); }
bad()  { ROWS+=("🔴 $1"); TODO+=("$2"); RED=1; }
info() { ROWS+=("ℹ️  $1"); }

hr; say "$(L 'Студентський комплект — встановлення одним заходом' 'Student kit — one-shot installation')"
say "$(L 'Проєкт' 'Project'): $PROJECT_DIR"; hr

# ── 1. Prerequisites ──────────────────────────────────────────────────────────
say "1/7 $(L 'Передумови' 'Prerequisites')"
have() { command -v "$1" >/dev/null 2>&1; }
for t in git curl; do
  if have "$t"; then say "   ✓ $t"; else
    say "   ✗ $t $(L 'НЕ знайдено' 'NOT found')"
    bad "$t $(L 'відсутній' 'is missing')" "$(L "Постав $t і запусти скрипт знову" "Install $t and run the script again")"; fi
done
if have python3 || have python || have jq; then say "   ✓ python $(L 'або' 'or') jq"; else
  say "   ✗ $(L 'ні python, ні jq' 'neither python nor jq')"
  bad "$(L 'python/jq відсутні' 'python/jq missing')" "$(L 'Постав python3 (python.org) або jq — потрібен для критиків через API' 'Install python3 (python.org) or jq — needed for the API-based critics')"; fi
if have codex; then say "   ✓ codex (Codex CLI)"; else
  say "   ⚠ codex $(L 'не в PATH' 'not on PATH')"
  bad "$(L 'Codex CLI не в PATH' 'Codex CLI not on PATH')" "$(L 'Скіли ставляться, але критик codex-cli не запуститься: перевір, що Codex встановлено і команда claude працює в цьому терміналі' 'Skills will install, but the codex-cli critic cannot run: make sure Codex is installed and the codex command works in this terminal')"; fi

# ── 2. Project = git repo, run from its root ──────────────────────────────────
say "2/7 $(L 'Git-репозиторій проєкту' 'Project git repository')"
if ! git rev-parse --is-inside-work-tree >/dev/null 2>&1; then
  git init -q && say "   ✓ $(L 'створено новий git-репозиторій (тут його не було)' 'created a new git repository (there was none here)')" \
    || bad "$(L 'git init не вдався' 'git init failed')" "$(L "Розберись із текою проєкту: $PROJECT_DIR" "Check the project folder: $PROJECT_DIR")"
fi
if [ -n "$(git rev-parse --show-prefix 2>/dev/null)" ]; then
  say "   ✗ $(L 'це ПІДТЕКА репозиторію, а не корінь' 'this is a SUBFOLDER of the repository, not its root'): $(git rev-parse --show-toplevel)"
  bad "$(L 'Скрипт запущено не з кореня репозиторію' 'Script was run outside the repository root')" "cd $(git rev-parse --show-toplevel) && bash scripts/bootstrap-codex.sh"
  say ""; say "$(L "Зупиняюсь: пам'ять у підтеці жоден чат не знайде." 'Stopping: memory placed in a subfolder is invisible to every chat.')"; exit 1
fi
if [ -z "$(git config user.email 2>/dev/null)" ]; then
  bad "$(L 'git не знає твого email' 'git does not know your email')" "$(L 'git config --global user.email "твій@email" (і user.name) — без цього коміти не працюють' 'git config --global user.email "you@example.com" (and user.name) — commits do not work without it')"
else
  say "   ✓ git user.email: $(git config user.email)"
fi

# ── 3. parallel-ai-dev (project memory) ───────────────────────────────────────
say "3/7 $(L 'Комплект «пам'\''ять проєкту» (parallel-ai-dev)' 'Project-memory kit (parallel-ai-dev)')"
PAD_DIR=""
for d in "$KIT_HOME/parallel-ai-dev" "$PROJECT_DIR/../parallel-ai-dev" "$PROJECT_DIR/../../parallel-ai-dev"; do
  if [ -d "$d/.git" ]; then PAD_DIR="$(cd "$d" && pwd)"; break; fi
done
if [ -n "$PAD_DIR" ]; then
  say "   • found: $PAD_DIR — using existing checkout without updating it"
else
  PAD_DIR="$KIT_HOME/parallel-ai-dev"
  if git clone -q "$PAD_REPO" "$PAD_DIR" 2>/dev/null; then say "   ✓ $(L 'склоновано у' 'cloned into') $PAD_DIR"; else
    bad "$(L 'Не вдалося склонувати parallel-ai-dev' 'Could not clone parallel-ai-dev')" "$(L "Перевір мережу і запусти: git clone $PAD_REPO $PAD_DIR" "Check the network and run: git clone $PAD_REPO $PAD_DIR")"; PAD_DIR=""; fi
fi
if [ -n "$PAD_DIR" ]; then
  say "   • init-memory $(L 'у проєкті' 'in the project') $(L '' '(the kit prints in Ukrainian — Codex translates for you)'):"
  if (cd "$PROJECT_DIR" && bash "$PAD_DIR/scripts/init-memory.sh" 2>&1 | sed 's/^/     /'); then
    ok "$(L "Пам'ять проєкту розгорнута" 'Project memory deployed') ($PAD_DIR)"
  else
    bad "$(L 'init-memory.sh повернув помилку' 'init-memory.sh returned an error')" "$(L "Прочитай вивід вище і запусти: cd $PROJECT_DIR && bash $PAD_DIR/scripts/init-memory.sh" "Read the output above and run: cd $PROJECT_DIR && bash $PAD_DIR/scripts/init-memory.sh")"
  fi
fi

# ── 4. Skills /tz-* ──────────────────────────────────────────────────────────
say "4/7 $(L 'Скіли Codex' 'Codex skills') → $SKILLS_DIR"
mkdir -p "$SKILLS_DIR"
INSTALLED=0
for s in tz-draft tz-review tz-verify tz-go; do
  src="$TZ_ROOT/skills/$s"; dst="$SKILLS_DIR/$s"
  [ -d "$src" ] || continue
  if [ -e "$dst" ]; then
    if diff -qr "$src" "$dst" >/dev/null 2>&1; then
      say "   ✓ /$s (already installed)"; INSTALLED=$((INSTALLED+1))
    else
      say "   ✗ /$s differs; preserved existing files for manual review"
    fi
  elif cp -R "$src" "$dst"; then
    say "   ✓ /$s"; INSTALLED=$((INSTALLED+1))
  else
    say "   ✗ /$s failed to copy"
  fi
done
if [ "$INSTALLED" -eq 4 ]; then ok "$(L '4 скіли /tz-draft /tz-review /tz-verify /tz-go встановлено' '4 skills /tz-draft /tz-review /tz-verify /tz-go installed')"; else
  bad "$(L "Встановлено $INSTALLED/4 скілів" "Installed $INSTALLED/4 skills")" "$(L "Перевір права на $SKILLS_DIR і запусти: bash $TZ_ROOT/lib/tz-skills-update.sh" "Check permissions on $SKILLS_DIR and run: bash $TZ_ROOT/lib/tz-skills-update.sh")"; fi

# ── 5. Critics: providers.json + NVIDIA key ──────────────────────────────────
say "5/7 $(L 'Критики' 'Critics') (providers.json → $PROVIDERS)"
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
    info "$(L 'NVIDIA_API_KEY є в ~/.bashrc, але не в цьому терміналі — після перезапуску терміналу підхопиться' 'NVIDIA_API_KEY is in ~/.bashrc but not in this terminal — it will be picked up after a terminal restart')"
  fi
  info "NVIDIA is optional and not configured; two additional critics are unavailable"
else
  say "   ✓ NVIDIA_API_KEY $(L 'є в оточенні' 'present in the environment')"
fi

# ── 6. IMMUNE in the project's AGENTS.md ──────────────────────────────────────
say "6/7 IMMUNE — $(L 'правила проти гниття коду' 'rules against code rot') → AGENTS.md"
if [ "$KIT_LANG" = "en" ]; then BLOCK="$TZ_ROOT/docs/IMMUNE_CLAUDE_BLOCK.en.md"; else BLOCK="$TZ_ROOT/docs/IMMUNE_CLAUDE_BLOCK.md"; fi
if [ ! -f "$BLOCK" ]; then
  bad "$(L "Файл $BLOCK не знайдено" "File $BLOCK not found")" "$(L "Онови tz-skills: git -C $TZ_ROOT pull --ff-only" "Update tz-skills: git -C $TZ_ROOT pull --ff-only")"
elif [ -f "$PROJECT_DIR/AGENTS.md" ] && grep -qE 'Правила проти гниття коду \(IMMUNE\)|Rules against code rot \(IMMUNE\)' "$PROJECT_DIR/AGENTS.md"; then
  say "   • $(L 'блок уже є — не дублюю' 'block already present — not duplicating')"; ok "$(L 'IMMUNE уже в AGENTS.md' 'IMMUNE already in AGENTS.md')"
else
  { printf '\n'; cat "$BLOCK"; } >> "$PROJECT_DIR/AGENTS.md" && { say "   ✓ $(L 'дописано в кінець AGENTS.md' 'appended to the end of AGENTS.md')"; ok "$(L 'IMMUNE дописано в AGENTS.md' 'IMMUNE appended to AGENTS.md')"; } \
    || bad "$(L 'Не вдалося дописати IMMUNE' 'Could not append IMMUNE')" "$(L "Скопіюй вміст $BLOCK у кінець $PROJECT_DIR/AGENTS.md руками" "Copy the contents of $BLOCK to the end of $PROJECT_DIR/AGENTS.md by hand")"
fi

# ── 7. Checks (commits are deliberate, separate actions) ─────────────────────
say "7/7 Checks"
say "   • $(L "self-check пам'яті" 'memory self-check') $(L '' '(Ukrainian output — Codex translates)'):"
if [ -n "$PAD_DIR" ]; then
  if (cd "$PROJECT_DIR" && bash "$PAD_DIR/scripts/self-check.sh" 2>&1 | sed 's/^/     /'); then
    ok "self-check: ✅ $(L 'СИСТЕМА ГОТОВА' 'SYSTEM READY')"
  else
    bad "$(L "self-check пам'яті має червоні рядки (це очікувано на свіжій системі)" 'memory self-check has red rows (expected on a fresh system)')" "$(L "CLAUDE: заповни coordination/SETUP.md (visibility, mode), coordination/PROJECT_MAP.md (що в проєкті вже є), coordination/DECISIONS.md (3-5 рішень з полем «Чому»), секцію «Зони цього проєкту» в CLAUDE.md; закоміть і запуш; повтори bash $PAD_DIR/scripts/self-check.sh" "CODEX: fill in coordination/SETUP.md (visibility, mode), coordination/PROJECT_MAP.md (what already exists in the project), coordination/DECISIONS.md (3-5 decisions with a 'Why' field), the project-zones section of AGENTS.md; commit and push; rerun bash $PAD_DIR/scripts/self-check.sh")"
  fi
fi

say "   • $(L 'smoke-тест критиків' 'critics smoke test'):"
if [ -z "${NVIDIA_API_KEY:-}" ]; then
  if TZ_PROVIDERS_CONFIG="$PROVIDERS" bash "$ADAPTER_DIR/llm-critic.sh" --smoke critic_a 2>&1 | sed 's/^/     /'; then
    ok "Codex critic responds"
  else
    bad "Codex critic failed" "Run bash scripts/llm-critic.sh --smoke critic_a and resolve the reported error"
  fi
  info "Full three-critic review unavailable; optional NVIDIA setup skipped"
else
  if TZ_PROVIDERS_CONFIG="$PROVIDERS" bash "$ADAPTER_DIR/llm-critic.sh" --smoke-all 2>&1 | sed 's/^/     /'; then
    ok "Critics: all 3 slots respond"
  else
    bad "Critics: not all 3 slots respond" "Run bash scripts/llm-critic.sh --smoke-all and resolve the reported errors"
  fi
fi

# ── Summary ───────────────────────────────────────────────────────────────────
hr; say "$(L 'ПІДСУМОК' 'SUMMARY')"; hr
for r in "${ROWS[@]}"; do say "$r"; done
if [ "$RED" -eq 1 ]; then
  hr; say "$(L 'ЩО ЗРОБИТИ (по одному пункту, зверху вниз):' 'WHAT TO DO (one item at a time, top to bottom):')"
  i=1; for t in "${TODO[@]}"; do say "$i. $t"; i=$((i+1)); done
  hr; say "$(L 'Червоне — не поломка, а чек-лист. Коли все зроблено — запусти скрипт ще раз: він нічого не перезапише.' 'Red is not a failure — it is a checklist. When everything is done, run the script again: existing skill folders are preserved.')"
  exit 1
fi
hr; say "✅ $(L 'Усе зелене. Команди' 'Required setup checks passed. Commands'): /tz-go ($(L 'усе сам' 'everything on its own')) · /tz-draft · /tz-review · /tz-verify"
exit 0

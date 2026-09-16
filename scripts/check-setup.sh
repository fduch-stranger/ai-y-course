#!/usr/bin/env bash
set -euo pipefail
cd "$(dirname "${BASH_SOURCE[0]}")/.."
for script in scripts/bootstrap-codex.sh scripts/llm-critic.sh scripts/check-setup.sh scripts/memory-self-check.sh; do
  bash -n "$script"
done
for skill in tz-draft tz-review tz-verify tz-go; do
  test -s ".agents/skills/$skill/SKILL.md"
done
for file in AGENTS.md CLAUDE.md providers.json; do test -s "$file"; done
python3 -m json.tool providers.json >/dev/null
printf '%s\n' 'Local files, shell syntax, and provider JSON: OK'
memory_check="scripts/memory-self-check.sh"
if [ ! -f "$memory_check" ]; then
  printf '%s\n' "Missing English memory checker: $memory_check" >&2
  exit 1
fi
bash "$memory_check"

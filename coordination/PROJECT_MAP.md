# Project map — what already exists

| Component | Purpose | Status | Canonical location |
| --- | --- | --- | --- |
| Codex instructions | Canonical rules, project zones, IMMUNE, and TZ adaptations | Active | `AGENTS.md` |
| Legacy checker pointer | Redirects to AGENTS.md; required by upstream memory checker | Compatibility only | `CLAUDE.md` |
| Working memory | Decisions, map, backlog, lessons, workstreams, handoffs | Active | `coordination/` |
| TZ skills | Draft, review, verify, end-to-end workflow | Installed; full critic stages optional/unavailable | `.agents/skills/` |
| Bootstrap adapter | Non-destructive installation and setup check; NVIDIA optional | Active | `scripts/bootstrap-codex.sh` |
| Critic dispatcher | Codex CLI plus optional hosted critics | Codex smoke passed; hosted slots unconfigured | `scripts/llm-critic.sh` |
| Critic configuration | Backend and model selection, no secrets | Active | `providers.json` |
| Setup check | Script syntax, installed files, memory validation | Active | `scripts/check-setup.sh` |
| English memory checker | Translated upstream diagnostics, preserved validation rules | Active | `scripts/memory-self-check.sh` |
| Serena | Semantic tool configuration and compact memory pointers | Active | `.serena/` |
| Original kit rules | English translation of upstream rules for comparison | Reference only | `CLAUDE.parallel-ai-dev.md` |

External source checkouts: `~/tz-skills` and `~/parallel-ai-dev`. Repository copies and adapters are the runtime sources for skills and critic calls; the English memory checker is `scripts/memory-self-check.sh`, using the upstream VERSION and template files from `~/parallel-ai-dev`.

No application, framework, database, package manifest, application test suite, CI, remote repository, or deployment exists. Do not invent product architecture from the starter kit.

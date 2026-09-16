# Project map — what already exists

| Component | Purpose | Status | Canonical location |
| --- | --- | --- | --- |
| Codex instructions | Loads project rules and maps TZ workflows to Codex | Active | `AGENTS.md` |
| Project rules | Project zones, memory discipline, IMMUNE | Active | `CLAUDE.md` |
| Working memory | Decisions, map, backlog, lessons, workstreams, handoffs | Active | `coordination/` |
| TZ skills | Draft, review, verify, end-to-end workflow | Installed; full critic stages optional/unavailable | `.agents/skills/` |
| Bootstrap adapter | Non-destructive installation and setup check; NVIDIA optional | Active | `scripts/bootstrap-codex.sh` |
| Critic dispatcher | Codex CLI plus optional hosted critics | Codex smoke passed; hosted slots unconfigured | `scripts/llm-critic.sh` |
| Critic configuration | Backend and model selection, no secrets | Active | `providers.json` |
| Setup check | Script syntax, installed files, memory validation | Active | `scripts/check-setup.sh` |
| Serena | Semantic tool configuration and compact memory pointers | Active | `.serena/` |
| Original kit rules | Unmodified Ukrainian source for comparison | Reference only | `CLAUDE.parallel-ai-dev.md` |

External source checkouts: `~/tz-skills` and `~/parallel-ai-dev`. Repository copies and adapters are the runtime sources for skills and critic calls; the upstream memory self-check runs from `~/parallel-ai-dev`.

No application, framework, database, package manifest, application test suite, CI, remote repository, or deployment exists. Do not invent product architecture from the starter kit.

# Project map — what already exists

| Component | Purpose | Status | Canonical location |
| --- | --- | --- | --- |
| Codex instructions | Canonical rules, project zones, IMMUNE, and TZ adaptations | Active | `AGENTS.md` |
| Legacy checker pointer | Redirects to AGENTS.md; required by upstream memory checker | Compatibility only | `CLAUDE.md` |
| Working memory | Decisions, map, backlog, lessons, workstreams, handoffs | Active | `coordination/` |
| Course alignment | Maps the original Claude starter prompt to this Codex port and records the remaining gate | Active | `coordination/COURSE_ALIGNMENT.md` |
| TZ skills | Draft, review, verify, end-to-end workflow | Installed; read-only LLM smoke passed; full critic stages await NVIDIA | `.agents/skills/` |
| Bootstrap adapter | Non-destructive Codex port of the course installer | Active; reports red until the required course critics work | `scripts/bootstrap-codex.sh` |
| Critic dispatcher | Codex CLI plus NVIDIA-hosted critics | Critic A passed; B/C configured and waiting for `NVIDIA_API_KEY` | `scripts/llm-critic.sh` |
| Critic configuration | Backend and model selection, no secrets | Active | `providers.json` |
| Setup check | Script syntax, installed files, memory validation | Active | `scripts/check-setup.sh` |
| English memory checker | Translated upstream diagnostics, preserved validation rules | Active | `scripts/memory-self-check.sh` |
| Serena | Semantic tool configuration and compact memory pointers | Active | `.serena/` |
| Original kit rules | English translation of upstream rules for comparison | Reference only | `CLAUDE.parallel-ai-dev.md` |

External source checkouts are present at the pinned course revisions: `~/tz-skills` (`8fbe187c316e788fcf5d9da36bd0ebf0c19f79c5`) and `~/parallel-ai-dev` (`706aae5fc19c7a023b62e4e343468c76f2373e56`, kit 2.0.2). Repository copies and adapters are the runtime sources for skills and critic calls; the English memory checker uses the upstream VERSION and template files from `~/parallel-ai-dev`.

No application, framework, database, package manifest, application test suite, CI, or deployment exists. The starter kit itself is published on `origin/main`. Do not invent product architecture from the starter kit.

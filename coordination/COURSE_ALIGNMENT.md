# Course alignment

This file maps the original Claude Code starter prompt to the maintained Codex port. Platform-specific substitutions are explicit; missing capabilities remain red rather than being counted as equivalent.

| Original course requirement | Codex-port implementation | Status |
| --- | --- | --- |
| Claude Code installed and signed in | Codex CLI is the active agent and critic A; Claude is intentionally not installed | Compatible platform substitution |
| `~/tz-skills` source checkout | Pinned checkout at revision `8fbe187c316e788fcf5d9da36bd0ebf0c19f79c5` | Ready |
| `~/parallel-ai-dev` memory kit | Pinned checkout at revision `706aae5fc19c7a023b62e4e343468c76f2373e56`, version 2.0.2 | Ready |
| Project memory | Setup, project map, decisions, mistakes, backlog, workstreams, inbox, and session logs under `coordination/` | Ready |
| Four `/tz-*` commands | Project-local `$tz-draft`, `$tz-review`, `$tz-verify`, and `$tz-go`; original slash names are routed by `AGENTS.md` | Ready; all four passed a read-only LLM smoke probe |
| IMMUNE rules | Seven active rules in `AGENTS.md` | Ready |
| Three independent free critics | OpenAI Codex + MiniMax through NIM + NVIDIA Nemotron through NIM | Blocked: `NVIDIA_API_KEY` is missing; only critic A has passed |
| One batched setup interview | Public visibility, solo mode, project name, risk zones, check command, and no deploy command are recorded | Ready |
| Commit and push when a remote exists | Public `origin/main` is configured, reachable, and synchronized | Ready |
| Final all-green bootstrap | Codex bootstrap preserves local work and runs memory plus critic checks | Blocked only by the missing NVIDIA key and B/C smoke tests |

Base drafting, implementation, Serena, project memory, IMMUNE, and local Codex verification are usable while the final course critic gate is red. Do not describe the project as fully course-ready until `bash scripts/llm-critic.sh --smoke-all` passes and confirms three distinct model vendors.

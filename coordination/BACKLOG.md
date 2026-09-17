# Deferred work

- [x] **OWNER-SETUP** — Owner selected public visibility and accepted defaults: ai-y-course, one chat, no application risk areas or deployment yet.
- [x] **REMOTE** — `origin` is configured at `https://github.com/fduch-stranger/ai-y-course.git`; `main` is published and synchronized.
- [ ] **COURSE-CRITICS** — Owner supplies `NVIDIA_API_KEY`; store it outside Git, load it into the environment, allow the bootstrap to select live free NIM models if needed, and require `bash scripts/llm-critic.sh --smoke-all` to pass with three distinct vendors.
- [ ] **LAYERED-MEMORY-AUTOMATION** — Choose private storage for raw L1 histories, then build a Codex-compatible task export and automated L2 digest/WIP process. Never write raw histories to this public repository. Current L2 coverage is manual and indexed in `coordination/briefs/README.md`.
- [ ] **PRODUCT** — Select application stack, tests, and deployment when a concrete product task exists.

## Readiness audit — 2026-09-17

- [x] **REMOTE-DOCS** — Reconciled active remote statements after verifying `origin/main` matches local `main`.
- [ ] **CLI-WARNINGS** — Investigate user-level Codex CLI warnings if IDE integration or shell snapshots are needed: the `idea` MCP endpoint was unreachable, shell snapshot validation failed, and plugin icon paths were rejected. Critic A still returned PONG and passed its smoke test.

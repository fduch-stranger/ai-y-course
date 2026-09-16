# ai-y-course — Codex instructions

Read `CLAUDE.md` for the project rules and IMMUNE practices, and `coordination/SETUP.md` for the current setup. These are shared rules; the agent is Codex. The preserved upstream `CLAUDE.parallel-ai-dev.md` is reference material, not an additional active constitution.

Before substantial work, inspect Git status and read `coordination/PROJECT_MAP.md`, `coordination/DECISIONS.md`, and `coordination/BACKLOG.md`. Reuse existing work. Read `coordination/WORKSTREAMS.md` before editing alongside another chat. Activate this project in Serena and consult its core memory when available.

## Installed TZ workflows

The four skills are in `.agents/skills/`. Use `$tz-draft`, `$tz-review`, `$tz-verify`, or `$tz-go`; user messages using the original `/tz-*` names mean the corresponding skill. Read that skill's SKILL.md when invoked. Apply these Codex adaptations to upstream Claude-specific examples:

- Use the available Codex tools for reads, edits, shell execution, research, and subagents. Claude-specific tool names are examples, not required installations.
- The canonical critic dispatcher is `scripts/llm-critic.sh`. Resolve its absolute path from the project root; do not use upstream relative `../../lib` examples. `providers.json` is the canonical non-secret configuration.
- NVIDIA is optional by the user's instruction. Without it, drafting, implementation, and normal local checks can proceed. Full three-vendor `/tz-review` and `/tz-verify` remain unavailable until three distinct vendors pass smoke tests. Report this limitation explicitly; never label a single Codex review as three independent critics. `/tz-go` may continue with ordinary Codex review and local verification, recording that the full critic stages were skipped.
- For full verification with Codex orchestrating, use a configured non-OpenAI critic to extract acceptance criteria. Do not fall back to the orchestrator's own model and call it independent. Use the sequential verifier; the upstream Claude-only `--fanout` scripts are not supported here.
- Map background shell examples to bounded Codex process sessions. The host is macOS; check whether `timeout` exists before using it, or use a bounded subprocess runner.
- Do not delete files, including temporary prompts. Preserve existing changes. Instructions that treat silence as approval do not authorize external actions or resolve required user input.

## Checks

Run `bash scripts/check-setup.sh`. It validates the local setup and invokes the upstream memory check. Run `bash scripts/llm-critic.sh --smoke critic_a` when checking the Codex connection. Full critic checks are optional and require configured credentials plus a check that all three model vendors are distinct. No application tests or deployment exist yet.

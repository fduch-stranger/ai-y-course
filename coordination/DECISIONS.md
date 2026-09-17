# Decisions and reasons

## 2026-09-17 — Use Serena LSP for this project
**Decision:** Set the project-local Serena backend to LSP and enable Bash, Python, and TypeScript in `.serena/project.yml`. Bash remains the default for the existing shell scripts; TypeScript also covers JavaScript.
**Why:** The owner requested LSP for this project and subsequently requested Python and TypeScript support. An explicit project override preserves the global backend preference for other projects.
**Runtime:** Serena selects its backend at startup. Restart it with this project selected at startup to apply the override; a running JetBrains session cannot switch backends.

## 2026-09-17 — NVIDIA is optional for base work and required for full course readiness
**Decision:** Allow drafting, implementation, and normal local Codex checks without NVIDIA credentials. Keep the course bootstrap red until `NVIDIA_API_KEY` is configured and all three distinct-vendor critic slots pass smoke tests.
**Why:** The earlier owner decision prevented an optional credential from blocking useful work. The later request for course alignment requires preserving the original starter prompt's three-critic acceptance gate.
**Alternatives:** Calling one Codex critic equivalent to three independent critics was rejected. Blocking every local task on a hosted-provider credential was also rejected.

## 2026-09-17 — Preserve course behavior through an explicit Codex port
**Decision:** Use `AGENTS.md`, project-local `.agents/skills`, and `codex-cli` in place of the upstream Claude-specific locations and executable. Preserve the four workflows, project memory, IMMUNE rules, independent-vendor requirement, setup questions, commit/push discipline, and green/red bootstrap semantics.
**Why:** This project is operated with Codex, while the course prompt was written for Claude Code. Explicit substitutions keep the learning workflow intact without pretending Claude is installed.
**Alternatives:** Installing an unused Claude environment or silently mixing Claude and Codex instruction sources would create two competing runtimes.

## 2026-09-16 — Use Codex and project-local workflows
**Decision:** Install the four TZ skills in `.agents/skills/`, use `AGENTS.md` as the Codex entry point, and use Codex CLI for critic A.
**Why:** This workspace runs Codex and its CLI is available; Claude CLI is absent.
**Alternatives:** Installing Claude or changing global skills would add unnecessary dependencies or affect other projects.

## 2026-09-16 — Preserve existing files
**Decision:** The bootstrap preserves existing skill directories and reports differences; the dispatcher retains temporary prompts.
**Why:** The owner explicitly prohibited deleting files. Upstream installation and cleanup commands delete files.
**Alternatives:** Running the unmodified installer would violate that instruction.

## 2026-09-16 — Keep an English canonical memory
**Decision:** Store project knowledge in `coordination/` and compact pointers in Serena. Use self-managed English project rules; preserve upstream rules as reference.
**Why:** Future sessions need the existing decisions and map without competing active rule sets or duplicated facts.
**Alternatives:** Treating both the Ukrainian upstream constitution and a separate Codex constitution as active creates conflicting workflows.

## 2026-09-16 — Do not select a product stack during setup
**Decision:** Record the actual setup files only; no framework, application, database, or deployment is chosen.
**Why:** The project was empty and the user requested a starter kit, not an application.
**Alternatives:** A speculative application scaffold would exceed the request and create misleading memory.

## 2026-09-16 — Make AGENTS.md the sole instruction source
**Decision:** Keep all active rules and IMMUNE practices in AGENTS.md. CLAUDE.md is only a compatibility pointer required by the upstream memory checker.
**Why:** Claude filenames obscured that the project uses Codex. One active source clarifies ownership while preserving files and compatibility.
**Alternatives:** Deleting the legacy files would conflict with the owner's preservation instruction and break the original checker.

## 2026-09-16 — Keep the installed kit consistently English
**Decision:** Translate installed skills, retained kit rules, script comments, and diagnostic output. Preserve original legal notices and legacy input-matching expressions. Preserve English project versions on bootstrap reruns.
**Why:** Mixed upstream Ukrainian and English made the Codex adaptation harder to understand. English should cover both documentation and command output.
**Alternatives:** Translating only chat summaries leaves files and terminal checks inconsistent. Removing legal notices or changing validation rules is unnecessary.

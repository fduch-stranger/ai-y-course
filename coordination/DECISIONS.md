# Decisions and reasons

## 2026-09-16 — NVIDIA is optional
**Decision:** Allow local setup, drafting, implementation, and normal Codex verification without NVIDIA credentials. Mark full three-vendor review unavailable until configured and tested.
**Why:** The owner explicitly made NVIDIA optional; missing optional credentials must not block useful work.
**Alternatives:** Requiring a key was rejected. Three same-vendor agents would not satisfy the kit's independent-vendor requirement.

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

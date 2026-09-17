# Adapt Claude starter kit

- **Codex task:** `01a0a9fc-e91a-71f0-9bab-d0be6cfafd12`
- **Host:** remote Codex host
- **Started:** 2026-09-16
- **Purpose:** adapt the Claude-oriented starter prompt into a working Codex project kit, preserve the course workflow, and publish the initialized repository.

## Done

- Initialized the project memory, four project-local TZ workflows, IMMUNE rules, provider configuration, and Serena memory pointers.
- Made Codex the active runtime and critic A while retaining the upstream Claude compatibility files required by the checker.
- Standardized maintained instructions and diagnostics in English and preserved legal notices and legacy matching expressions.
- Made NVIDIA optional for ordinary work while preserving the three-independent-critic gate for full course readiness.
- Verified the setup, committed it, created the public GitHub repository, pushed `main`, and later synchronized remote changes.

## Decisions

- Use `AGENTS.md` as the canonical Codex instruction file and keep `CLAUDE.md` as a compatibility pointer.
- Keep the four workflows under `.agents/skills/` so they remain project-scoped.
- Preserve files during bootstrap and keep temporary critic prompts because deletion was prohibited.
- Store shared project knowledge in Git-tracked coordination files; use public-safe summaries because the repository is public.

## Unfinished

- Configure `NVIDIA_API_KEY` and verify three distinct critic vendors when full course-green review is needed.
- Raw transcript export and automated nightly digests were not installed during initialization.

## Pitfalls and lessons

- The initial adaptation mixed English and Ukrainian and left Claude-oriented naming ambiguous; later changes established one English Codex instruction source.
- A green base setup does not prove the three-critic course gate or the optional L1/L2 history automation.

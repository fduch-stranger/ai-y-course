# Check project readiness

- **Codex task:** `01a0ae2b-e55a-7443-a510-5e735052d4a5`
- **Host:** local Codex host
- **Started:** 2026-09-17
- **Purpose:** verify that the starter kit works, align it with the course, configure Serena, and explain the kit's memory and IMMUNE behavior.

## Done

- Confirmed all four project-local TZ workflows are available and exercised bounded smoke paths.
- Configured Serena to use the project-local LSP backend with Bash, Python, and TypeScript; a fresh health check passed symbol and search operations.
- Ran the setup checker and critic A smoke test, fixed the bootstrap's IMMUNE check ordering, and kept the missing NVIDIA critics explicit.
- Restored and pinned the upstream `tz-skills` checkout, documented course substitutions, corrected stale remote statements, committed, and pushed the verified changes.
- Explained IMMUNE, skill scope, one-critic limitations, and the Git-tracked shared-memory files.
- Audited the Codex app task inventory: two tasks belong to this project. Added one sanitized brief for each task.

## Decisions

- Use Serena LSP with Bash, Python, and TypeScript for this project.
- Ordinary drafting and implementation may proceed with critic A; full `$tz-review` and `$tz-verify` require three independent vendors.
- Treat the existing coordination records as Layer L3, per-task briefs as Layer L2, and raw private histories as Layer L1.

## Unfinished

- `NVIDIA_API_KEY` remains optional and unconfigured, so the full course critic gate is red.
- Codex-compatible automatic L1 export and nightly L2 digest generation are not configured. The owner must first choose private storage for raw histories.

## Pitfalls and lessons

- The earlier readiness answer described shared project memory correctly but did not state that task-by-task briefs and private transcript export were absent.
- Daily logs summarize work by date and cannot prove that every task has a brief; coverage must be matched by stable task ID.
- Raw task histories can contain personal data and credentials, so they do not belong in this public repository.

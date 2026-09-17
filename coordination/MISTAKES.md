# Lessons learned

## 2026-09-16 — Upstream installer claimed preservation but deleted skill directories
**Cause:** The copy loop used recursive deletion before replacement.
**Rule:** Inspect installer mutations before running them. Preserve existing folders and report differing content for review.

## 2026-09-16 — Copied Claude skills assume their original directory layout
**Cause:** Critic examples resolve `../../lib/llm-critic.sh`, which is not installed with the standalone skill directories.
**Rule:** Resolve the repository's canonical `scripts/llm-critic.sh` as specified in `AGENTS.md`; do not copy relative examples blindly.

## 2026-09-17 — Bootstrap required an unused external IMMUNE source
**Cause:** The bootstrap checked for the upstream English IMMUNE source file before checking whether the project already contained the required block.
**Rule:** Check satisfied project state before requiring an installation source. External source material is needed only when the project must be changed.

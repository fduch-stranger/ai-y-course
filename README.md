# ai-y-course

Codex starter workspace with project memory, IMMUNE rules, and four TZ workflows. No application has been created yet.

`AGENTS.md` is the canonical Codex instruction file. `CLAUDE.md` is only a pointer retained for the original memory checker; `CLAUDE.parallel-ai-dev.md` is archived upstream reference material. Claude is not required. The copied skill text still contains upstream Claude examples; the explicit adaptations in AGENTS.md map those examples to Codex. The Claude-only verifier fan-out is unsupported; use the sequential path.

Use `$tz-draft` to turn an idea into a specification, `$tz-review` for a full three-critic review, `$tz-verify` for full verification, or `$tz-go` for the complete workflow. The original `/tz-*` names are recognized by the project instructions when sent as text. Full review and verification require three working vendors; NVIDIA is optional and these stages are currently unavailable. Ordinary Codex work and local checks remain available.

Run `bash scripts/check-setup.sh` to check local setup. Run `bash scripts/bootstrap-codex.sh` to rerun the adapted installer; it preserves existing skills, provider configuration, and upstream checkouts. Commit changes separately after reviewing them. Do not use the unmodified upstream installer for this project because it deletes existing skill directories.

Project status and pending owner choices: `coordination/SETUP.md`. Existing components: `coordination/PROJECT_MAP.md`. Design reasons: `coordination/DECISIONS.md`. Deferred work: `coordination/BACKLOG.md`.

Sources: [tz-skills](https://github.com/ymaxymovych/tz-skills), revision `8fbe187c316e788fcf5d9da36bd0ebf0c19f79c5`; [parallel-ai-dev](https://github.com/ymaxymovych/parallel-ai-dev), revision `706aae5fc19c7a023b62e4e343468c76f2373e56`. The copied TZ skills are unchanged; `AGENTS.md` defines the Codex adaptations. See `THIRD_PARTY_LICENSES.md` for the bundled source licenses.

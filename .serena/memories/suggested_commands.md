# Commands

- `bash scripts/check-setup.sh`: local file and syntax checks, then scripts/memory-self-check.sh (English translation of upstream validation; uses upstream VERSION/templates).
- `bash scripts/llm-critic.sh --smoke critic_a`: live Codex connectivity.
- `bash scripts/bootstrap-codex.sh`: adapted installer; preserves installed English skills and existing configuration. Commit changes separately after review. Do not substitute the destructive upstream installer.
- No application or deploy command exists; consult coordination/SETUP.md.

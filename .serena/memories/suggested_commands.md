# Commands

- `bash scripts/check-setup.sh`: local file and syntax checks, then upstream memory checker.
- `bash scripts/llm-critic.sh --smoke critic_a`: live Codex connectivity.
- `bash scripts/bootstrap-codex.sh`: adapted installer; creates missing files and preserves existing configuration. Commit changes separately after review. Do not substitute the destructive upstream installer.
- No application or deploy command exists; consult coordination/SETUP.md.

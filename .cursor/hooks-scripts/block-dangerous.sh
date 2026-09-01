#!/usr/bin/env bash
# Reads hook JSON on stdin, blocks destructive commands.
# Exit codes / JSON response: verify against current Cursor hooks docs.
INPUT=$(cat)
CMD=$(echo "$INPUT" | sed -nE 's/.*"command" *: *"(([^"\\]|\\.)*)".*/\1/p' | head -1)

DENY='rm -rf +(/|~|\.|\$HOME|[a-z]+/)|git push .*(--force|-f( |$)|--force-with-lease)|git reset --hard|git clean -[a-z]*f|git checkout -- \.|git branch -D|git push origin :|DROP (TABLE|DATABASE|SCHEMA)|truncate table|--no-verify|(curl|wget) .*\| *(ba|z|da)?sh|gh pr (merge|close|review .*--approve)|gh issue (delete|close)|gh repo (delete|edit|archive)|gh secret (set|delete)|gh api -X (PUT|DELETE|PATCH) .*(protection|permissions|secrets)'

if echo "$CMD" | grep -Eiq "$DENY"; then
  echo '{"permission":"deny","userMessage":"Blocked by Massner guardrail: destructive or unsafe command. Ask a human."}'
  exit 0
fi
echo '{"permission":"allow"}'

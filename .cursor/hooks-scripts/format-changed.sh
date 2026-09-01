#!/usr/bin/env bash
# Auto-format after agent edits. Swap in your formatter per stack.
INPUT=$(cat)
FILE=$(echo "$INPUT" | grep -o '"file_path" *: *"[^"]*"' | sed 's/.*: *"//;s/"$//')
[ -z "$FILE" ] && exit 0
case "$FILE" in
  *.ts|*.tsx|*.js|*.jsx|*.json|*.css|*.md) npx --yes prettier --write "$FILE" >/dev/null 2>&1 ;;
  *.py) ruff format "$FILE" >/dev/null 2>&1 ;;
  *.dart) dart format "$FILE" >/dev/null 2>&1 ;;
esac
exit 0

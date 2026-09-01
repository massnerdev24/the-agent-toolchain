#!/usr/bin/env bash
# Runs when the agent tries to finish. Only enforces tests on implementation
# branches (agent/<id>-t<N>-*); spec/plan/audit/bootstrap work is exempt.
# MASSNER_TEST_CMD is set by /bootstrap-project in .cursor/massner.env.
[ -f ./.cursor/massner.env ] && . ./.cursor/massner.env
TEST_CMD="${MASSNER_TEST_CMD:-npm test --silent}"
BRANCH=$(git rev-parse --abbrev-ref HEAD 2>/dev/null)
COUNT_FILE="/tmp/massner-verify-count-${BRANCH//\//_}"
find /tmp -name 'massner-verify-count-*' -mmin +240 -delete 2>/dev/null

case "$BRANCH" in
  agent/*-t[0-9]*) ;;                       # implementation branch: enforce
  *) echo '{"continue":true}'; exit 0 ;;    # everything else: exempt
esac

# A draft PR on this branch means the agent stopped deliberately (spec
# deviation, or review round 3/3). Skill STOP conditions outrank this hook
# (AGENTS.md § Precedence), so let the stop through.
if command -v gh >/dev/null 2>&1 &&
   [ "$(gh pr view "$BRANCH" --json isDraft --jq .isDraft 2>/dev/null)" = "true" ]; then
  echo '{"continue":true}'; exit 0
fi

N=$(( $(cat "$COUNT_FILE" 2>/dev/null || echo 0) + 1 )); echo "$N" > "$COUNT_FILE"
if [ "$N" -gt 3 ]; then
  echo '{"continue":true,"agentMessage":"Tests still failing after 3 attempts. Stop. Open the PR as a DRAFT, paste the failing output under \"How it was tested\", and ask a human."}'
  exit 0
fi

if $TEST_CMD >/tmp/massner-test-out.txt 2>&1; then
  rm -f "$COUNT_FILE"; echo '{"continue":true}'
else
  TAIL=$(tail -c 800 /tmp/massner-test-out.txt | tr '"' "'" | tr '\n' ' ')
  echo "{\"continue\":false,\"agentMessage\":\"Tests are failing (attempt ${N}/3). If you are mid-implementation, fix them. If you stopped deliberately for a spec deviation, open the PR as a DRAFT first — this hook lets you finish once a draft PR exists on this branch. Output tail: ${TAIL}\"}"
fi

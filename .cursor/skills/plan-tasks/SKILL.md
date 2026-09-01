---
name: plan-tasks
description: Break an approved spec into ordered implementation tasks. Use when asked to "plan", "break down", "create tasks from the spec", or after a spec PR is merged.
---

# Plan tasks from an approved spec

## Steps
1. Read the spec at the path provided (must have status APPROVED and an
   empty "Open questions" section — if not, STOP and report why).
2. If `docs/specs/PLAN-<ticket-id>.md` previously existed, or merged PRs
   matching `agent/<ticket-id>-t*` exist (`gh pr list --state merged --json
   number,headRefName --jq '.[] | select(.headRefName |
   startswith("agent/<ticket-id>-t"))'`), reconstruct which tasks are already
   shipped and mark them `[x]` with the PR number; never re-list shipped work
   as open.
3. Break the work into ordered tasks. Each task must be:
   - Independently implementable and testable
   - Small: roughly ≤ 200 lines of diff
   - Described with: goal, files touched, tests to write, done-check
4. Write the plan to `docs/specs/PLAN-<ticket-id>.md` as a markdown checklist.
5. Order tasks so the system builds up safely: schema/types → core logic →
   integration → UI → cleanup. Tests land WITH each task, not at the end.
6. Create branch `agent/<ticket-id>-plan` from latest `main`, commit only the
   PLAN file, and open a PR titled `plan(<ticket-id>): <title>` with label
   `stage:plan`. Never merge it.

## Handoff
Travis reviews and merges the plan PR; that merge is plan approval. The
`implement-task` skill only reads plans from `main`, so nothing is
implemented until the plan is merged. Each unchecked task in the merged plan
is one unit of work for `implement-task`.

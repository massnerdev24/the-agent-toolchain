---
name: build-backlog
description: Turn an approved Project Brief (and audit report, if any) into an organized, milestone-grouped ticket backlog. Use when asked to "build the backlog", "create tickets", "break the project into tickets", or after a project brief is approved.
---

# Build the initial backlog (Stage 0.5)

Input: `docs/PROJECT-BRIEF.md` with status APPROVED (stop if not), plus
`docs/audit/AUDIT-*.md` if the brief says EXISTING-CODE (stop if missing).

## Steps
1. Read the brief (and audit). List the v1 features and, for existing code,
   the Critical/High remediation items — those go in Milestone 0.
2. Group work into milestones that each end in something demonstrable:
   - M0: foundation (repo scaffold, CI, deploy pipeline, auth skeleton)
     — or remediation, for existing code
   - M1..Mn: one coherent feature slice each
   - Final: launch checklist (domains, monitoring, backups, handoff docs)
3. Write every ticket to `docs/backlog/BACKLOG.md` using the ticket format
   below. Rules per ticket:
   - Scoped to ONE spec — if you can't imagine a 2-page spec covering it,
     split it.
   - Sized S / M / L. Anything you'd call XL must be split.
   - Dependencies named by ticket ID.
   - 2–4 seed acceptance criteria (the write-spec skill will refine them).
4. Present the backlog to Travis. Iterate until he approves. Approval means
   Travis says "approved" (or equivalent) in chat — "looks good" is not
   approval; ask.
5. On approval ONLY: publish tickets as GitHub issues via `gh issue create`
   (or the GitHub MCP), one per ticket, with milestone + `size:` labels.
   After each create, rewrite the ticket's temporary id (T-01…) in
   BACKLOG.md to the real `GH-<issue number>` — every downstream artifact
   (spec, plan, branches, commits) keys off `GH-<n>`.
6. Open PR `chore(backlog): publish initial backlog` on
   `agent/repo-backlog` containing `docs/backlog/BACKLOG.md` with the
   rewritten `GH-<n>` ids. The issues are already live; this PR is the
   record and needs no spec. Travis merges it.
   Do NOT add the `agent:spec` label — Travis adds that per-ticket when he
   wants the pipeline to pick one up.

## Ticket format
```
### <ID> — <Imperative title>
Milestone: M<n> · Size: S|M|L · Depends on: <IDs or none>
**Goal:** <one sentence>
**Seed acceptance criteria:**
- ...
**Notes:** <constraints from the brief relevant to this ticket>
```

## Handoff
Each published issue enters the general-purpose loop when labeled
`agent:spec` → write-spec → plan-tasks → implement-task → review-pr.
This skill is one-time per project; the loop runs forever after for new
features, bugs, and changes.

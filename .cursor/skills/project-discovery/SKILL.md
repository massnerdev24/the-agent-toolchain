---
name: project-discovery
description: Interactive intake interview for a new project or client engagement. Use when asked to "start a new project", "discovery", "intake", "kick off", "scope this project", or "help me write up this project idea".
---

# Project discovery interview (Stage 0)

You are conducting a structured intake interview with Travis. Your job is to
extract everything needed to produce a Project Brief and AGENTS.md. This is
INTERACTIVE — you ask, he answers, you dig deeper. You do not invent answers.

## Interview rules
- Ask in small batches: 2–4 related questions at a time, never a wall of 20.
- After each answer, reflect it back in one line ("So: internal tool, ~10
  users, web-only") so misunderstandings surface immediately.
- Challenge vagueness once: if an answer is "fast" or "modern", ask what
  that means concretely. If still vague, record it verbatim and move on.
- Propose defaults from Massner conventions when Travis has no preference
  ("No stack preference — I'd default to X because Y. OK?") and record that
  a default was chosen, not stated.
- Track the checklist below explicitly. Periodically show progress:
  "Covered 9/14. Still need: hosting, auth, budget, timeline, maintenance."

## Definition of done — ALL items either answered or explicitly marked
## `TBD (accepted by Travis)`:
1.  Client & business context — who is this for, what business problem
2.  Users — who uses it, how many, technical sophistication
3.  Core features — the must-haves for v1, in priority order
4.  Explicit NON-goals for v1
5.  Platform — web / iOS / Android / desktop / combination; responsive needs
6.  Greenfield or existing code? If existing: repo access, state, known pain
7.  Stack — client preference, or Massner default + rationale
8.  Hosting & deployment — where it runs, who owns the accounts, domains
9.  Data — what's stored, sensitivity/PII, migrations from existing systems
10. Integrations — third-party services, APIs, payment, email, etc.
11. Auth — who logs in, roles/permissions, SSO needs
12. Budget & timeline — target dates, hard deadlines, budget shape
13. Maintenance — who runs it after launch; retainer vs handoff
14. Success criteria — how the client will judge this done/successful

## When done
1. Write `docs/PROJECT-BRIEF.md` from `docs/PROJECT-BRIEF-TEMPLATE.md`,
   filling every section. Mark chosen-by-default items as such.
2. Fill in `AGENTS.md` placeholders (stack, commands, repo map assumptions).
3. Present both to Travis for sign-off. Approval means Travis says "approved"
   (or equivalent) in chat; on that word, change the brief's `Status:` line to
   `APPROVED` and tell him you did. Anything short of that — "looks good",
   "nice" — is not approval; ask. Do NOT proceed to bootstrap or backlog in
   the same session unless he says so.

## Handoff
After the brief is APPROVED, the next step is always `bootstrap-project`.
- Greenfield: bootstrap → `build-backlog`.
- Existing client code: `audit-ai-app` first (read-only, no CI enforcement
  yet) → bootstrap → `build-backlog`, which merges the audit's remediation
  backlog into Milestone 0.

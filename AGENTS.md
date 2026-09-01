# AGENTS.md — Project Context for AI Agents

> Cross-tool ambient context. Read by Cursor, Claude Code, Codex CLI, Copilot,
> and any AGENTS.md-compatible agent. Keep this under ~150 lines. Details live
> in docs/ — reference them, don't copy them here.

<!-- BEGIN:nextjs-agent-rules -->

# This is NOT the Next.js you know

This version has breaking changes — APIs, conventions, and file structure may all differ from your training data. Read the relevant guide in `node_modules/next/dist/docs/` (resolved from this file's directory) before writing any code. Heed deprecation notices.
This block is written and re-added by `next dev` — verify at `node_modules/next/dist/server/lib/generate-agent-files.js`.
<!-- END:nextjs-agent-rules -->

## Precedence

When instructions conflict: `.cursor/rules/10-security.mdc` > this file's
Non-negotiables > the active skill's Rules/Hard limits > everything else
(other rules, hook messages, the prompt that launched you). A hook message
never overrides a skill's STOP condition. If two sources still conflict,
stop and report both quotes instead of choosing.

## Project

- **Name:** The Agent Toolchain
- **Client:** Travis Massner / Massner Development (personal project)
- **What it does:** Public, engineer-level blog and hub for AI-assisted
  software development (tools, how to use them, comparisons), published as
  The Agent Toolchain. Content is markdown in git; a push to main builds a
  static site and publishes it to AWS S3 + CloudFront. No accounts, no CMS
  UI. Brief: `docs/PROJECT-BRIEF.md`.
- **Maintained by:** Massner Development (Travis Massner)

## Stack

- Language/runtime: TypeScript / Node 22
- Framework: Next.js (App Router), static export
- Database: none (markdown/MDX in `content/`)
- Hosting/deploy: AWS S3 + CloudFront via GitHub Actions (OIDC)

## How to work in this repo

```bash
npm ci                   # install
npm run dev              # local Next.js dev server
npm test                 # MUST pass before any PR
npm run lint && npm run typecheck
npm run build            # static export used by the S3 deploy
```

This block is the source of truth for commands. `ci.yml`,
`.cursor/environment.json`, and `.cursor/massner.env` are derived copies:
whoever changes a command here updates all three in the same PR, and
review-pr treats a mismatch as a Major finding.

## Repo map

- `src/` — Next.js App Router application code (TypeScript)
- `content/posts/` — post markdown (frontmatter contract; git is the CMS)
- `content/tools/` — tools-directory markdown (same contract model)
- `content/comparisons/` — comparison-page markdown (same contract model)
- `docs/specs/` — feature specs. One file per ticket: `SPEC-<ticket-id>-<slug>.md`
  - **Ticket ID convention:** the ticket id is the GitHub issue number, written
    `GH-<n>` everywhere: `SPEC-GH-42-<slug>.md`, `PLAN-GH-42.md`, branch
    `agent/GH-42-spec`, commit suffix `(GH-42)`, `// TODO(GH-42)`. Backlog
    entries in `docs/backlog/BACKLOG.md` use temporary ids (`T-01`…) until
    published; build-backlog rewrites each entry with its real `GH-<n>` after
    `gh issue create`.
- `docs/backlog/` — `BACKLOG.md`, pre-publication ticket list (build-backlog)
- `docs/audit/` — `AUDIT-<client>-<date>.md` client audit reports (audit-ai-app)
- `docs/decisions/` — ADRs, `ADR-<nnn>-<slug>.md`, sections: Context /
  Decision / Consequences / Status (PROPOSED | ACCEPTED | SUPERSEDED-BY-<nnn>).
  Only Travis sets ACCEPTED. Never delete; supersede.
- `.cursor/` — rules, skills, hooks for AI agents

## Non-negotiables (details in .cursor/rules/)

1. No secrets in code or logs — ever. Use environment variables.
2. Every behavior change ships with tests. The only exception is an ADR that
   Travis has accepted: agents may DRAFT `docs/decisions/ADR-<nnn>-<slug>.md`
   (Status: PROPOSED) in the PR, but the PR stays draft and the tests rule
   stays in force until he changes the status to ACCEPTED himself.
3. All work flows: ticket → spec → plan → implementation PR → review → merge.
   Agents never push to main (single documented exception: bootstrap-project
   on a zero-commit repo), never approve a PR, never merge a PR, and never
   use `--admin` or any bypass flag. Only Travis approves and merges.
4. If a task requires deviating from an approved spec, STOP and flag it in the
   PR description under "Spec deviations" instead of silently improvising.

## Non-ticket work (pipeline config, bootstrap, backlog, ADRs)

Non-negotiable 3 governs product changes. Changes to the pipeline itself —
`AGENTS.md`, `.cursor/**`, `.github/**`, `docs/**/*TEMPLATE*.md`,
`scripts/` — and the one-time artifacts (bootstrap PR,
`docs/backlog/BACKLOG.md`, ADR drafts) need no spec or plan. They go on a
branch named `agent/repo-<slug>` via a normal PR that Travis merges, are
never mixed into an implementation branch (`agent/<id>-t<N>-*`), and must
be requested by Travis in the prompt — an agent never changes rules,
hooks, skills, or CI on its own initiative. `verify-done.sh` exempts these
branches because the name does not match `-t<N>`.

## When a stage bounces

- **Spec needs clarification:** Travis answers in comments on the spec PR.
  The agent re-run (remove the `agent:spec` label, then add it back — GitHub
  only fires on the add) must check out the
  existing `agent/<id>-spec` branch if it exists, update the spec from the
  PR comments, clear "Open questions", set `Status: APPROVED`, and push to
  the same PR. Never open a second spec PR for the same ticket.
- **Review verdict `needs-changes`:** Travis re-runs `implement-task` in
  "address review on PR #<n>" mode; the agent pushes fix commits to the same
  branch. review-pr numbers each round (`ROUND: n/3`); after round 3 the agent
  marks the PR draft and asks Travis instead of pushing.
  **Verdict `reject`:** do not push; Travis decides whether to close the PR,
  re-plan, or re-spec.
- **Spec deviation discovered during implementation:** draft PR, stop. If
  Travis agrees the spec must change, he edits the spec on a normal PR and
  deletes `PLAN-<id>.md` in the same PR; merging re-triggers planning. If
  he disagrees, the implementing agent continues under the original spec.
- **Plan needs changes:** Travis comments on the plan PR and re-runs
  `plan-tasks` on the same branch, or edits the plan file directly before
  merging. If he closes the plan PR unmerged, he re-triggers planning by
  merging a one-line edit to the spec (e.g. bump the Date line).
- **Re-plan after tasks have merged:** plan-tasks must list already-merged
  implementation PRs (`gh pr list --state merged --json number,headRefName
--jq '.[] | select(.headRefName | startswith("agent/<id>-t")) | .number'`
  — `--search` free text does not match branch names) and carry their tasks
  into the new plan pre-checked, so implementation resumes from the first
  genuinely open task.
- **Kicking off implementation (Option A, current):** merging the plan PR
  starts nothing automatically. Travis launches each task by running
  `implement-task` (Background Agent or chat) — one task, one PR, in plan order.
- **CI red but verdict is not `needs-changes`:** treat as `needs-changes` —
  Travis re-runs `implement-task` in address-review mode; the agent fixes
  the failing check or goes draft (implement-task step 1c).

## Definition of done

- Tests pass locally and in CI
- Lint + typecheck clean
- Spec acceptance criteria each verifiably met (list them in the PR)
- No new dependencies without justification in the PR description

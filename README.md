# The Agent Toolchain

Public, engineer-level hub for AI-assisted software development: tools,
how to use them, and comparisons. Content is markdown in git; a push to
`main` builds a static Next.js site and publishes it to AWS S3 + CloudFront.

**Project brief:** [`docs/PROJECT-BRIEF.md`](docs/PROJECT-BRIEF.md) (APPROVED)

## Commands

```bash
npm ci
npm run dev
npm test
npm run lint && npm run typecheck
npm run build
```

These must stay identical to `.github/workflows/ci.yml` and
`.cursor/massner.env`. See `AGENTS.md`.

## Agent pipeline

This repo uses the Massner agent pipeline (spec → plan → implement → review).
Setup after clone: `/bootstrap-project` has already been run for this project;
new work goes through GitHub issues labeled `agent:spec`.

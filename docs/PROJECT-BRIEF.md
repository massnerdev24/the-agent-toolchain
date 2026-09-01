# Project Brief — The Agent Toolchain

- **Client:** Travis Massner / Massner Development (personal project, not a client engagement)
- **Date:** 2026-09-01 · **Author:** project-discovery skill + Travis
- **Status:** APPROVED
- **Type:** GREENFIELD

## Business context

Independent, Travis-owned public site **The Agent Toolchain**. Not associated
with any client. It is a hub for software engineers who already work (or want
to work) with AI in their development workflow: which tools exist, how to use
them well, and other up-to-date, credible coverage of AI-assisted software
development.

Audience bar is “software-engineering-degree equivalent.” It is not for
people new to programming.

Why now: Travis wants a site that can be operated with a high degree of
automation later (AI drops a markdown file into the repo → the site
publishes it). v1 is the publishing machine and the public surface, not the
AI writer.

Public name: **The Agent Toolchain**. Byline remains Travis / Massner
Development. Custom domain is still unset (CloudFront default URL in v1).

## Users

- **Readers:** other software developers. Public, unbounded count. They
  expect engineer-level writing (code, tools, trade-offs), not beginner
  tutorials.
- **Author/operator:** Travis only. He writes or lands markdown in git.
  No other roles in v1.
- **Devices:** phone and desktop browsers. No native app, no offline-first.

## v1 scope

### Core features (priority order)

1. **Git-based publishing.** A markdown file with documented frontmatter
   (title, author, date published, tags/categories, and any other fields
   the contract requires), committed and pushed, appears live after the
   deploy pipeline runs. This is the v1 success bar.
2. **Posts** with tags/categories, rendered from `content/` (or equivalent)
   markdown collections.
3. **Tools directory** — same markdown-collection model as posts, so a
   future agent can add a tool page by dropping a file.
4. **Comparison pages** — same model as posts/tools.
5. **On-site search** across posts, tools, and comparisons. Static/in-repo
   (no hosted search product).
6. **RSS** feed of posts.

The frontmatter and folder contract for every collection must be documented
in-repo so a later AI workflow can generate valid files without changing
application code.

### Explicit non-goals for v1

- Logged-in write UI / traditional CMS (the repo is the CMS)
- User accounts, login, SSO
- Comments
- Newsletter / email capture
- Paid membership
- Community forum
- Job board
- Multi-author
- Ads (possible later if there is demand)
- AI content-generation pipeline (the site only renders markdown already in
  the repo; generation is a future add-on that uses the file contract)
- Analytics, contact forms, Discord/GitHub widgets, or other third-party
  product integrations
- Native apps, offline reading
- Custom domain (use the CloudFront default URL until Travis buys one)

## Platform & access

Web only. Responsive: must look correct on mobile and desktop. No native
app. No offline-first. Modern evergreen browsers are sufficient; no
specific legacy-browser requirement was stated.

Public site. No authentication.

## Technical decisions

| Decision   | Choice                                                                                                                                | Stated by client or Massner default?                                       | Rationale                                                                              |
| ---------- | ------------------------------------------------------------------------------------------------------------------------------------- | -------------------------------------------------------------------------- | -------------------------------------------------------------------------------------- |
| Stack      | Next.js (App Router) + TypeScript + Node 22                                                                                           | Massner default (Travis: no preference)                                    | Matches repo TypeScript conventions; static export fits git-content publishing         |
| Rendering  | Fully static (`output: 'export'` or equivalent)                                                                                       | Massner default                                                            | Required for S3+CloudFront; a dropped markdown file becomes HTML at build time         |
| Content    | Markdown/MDX files in git (`content/posts`, `content/tools`, `content/comparisons`)                                                   | Stated by Travis                                                           | Repo is the CMS; same contract for humans and future AI                                |
| Database   | None                                                                                                                                  | Massner default (Travis: git unless a need appears)                        | No accounts, no newsletter, no comments; nothing to persist at runtime                 |
| Hosting    | AWS S3 + CloudFront                                                                                                                   | Stated by Travis (AWS, not Amplify); Massner default for _which_ AWS shape | Lowest cost for a static blog; default `*.cloudfront.net` URL until a domain is bought |
| Deploy     | GitHub Actions: build on push to `main`, sync to S3, invalidate CloudFront. AWS auth via GitHub OIDC (no long-lived keys in the repo) | Massner default                                                            | Matches “push a file → live”; stays under the cost cap                                 |
| Auth       | None                                                                                                                                  | Stated by Travis                                                           | Public read-only site                                                                  |
| Search     | Static/on-site (e.g. Pagefind or equivalent; no Algolia)                                                                              | Massner default (Travis: “what you said is alright”)                       | No extra vendor bill                                                                   |
| Newsletter | Not in v1                                                                                                                             | Stated by Travis (changed from earlier must-have)                          | —                                                                                      |
| Domain     | CloudFront default hostname until Travis buys a domain                                                                                | Stated by Travis                                                           | No domain yet                                                                          |

Travis already has an AWS account. Credentials are never stored in the repo;
OIDC role + GitHub secrets/variables are configured at bootstrap/deploy
time by Travis.

## Data & integrations

**Stored:** markdown/MDX content and static assets in git only. No
application database. No subscriber list. No user profiles.

**PII:** none expected in v1 product data. Author name on posts is Travis’s
public byline, not a collected user record. Do not log IPs or emails in
app code (there is no form that would collect them).

**Integrations:** GitHub (source + Actions) and AWS (S3, CloudFront, IAM
OIDC). Nothing else in v1.

**Existing systems:** none to migrate.

## Constraints

- **Budget:** keep AWS + related costs **under $50/month**. S3+CloudFront
  at this traffic should be well under that (often a few dollars or less).
- **Timeline:** no hard deadline; ship when the publishing path is proven.
- **Account ownership:** Travis owns GitHub, AWS, and any future domain.
- **Compliance:** no stated regulatory regime. Still: no secrets in git,
  no unnecessary PII.

## Existing code

Greenfield. This repo currently holds the Massner agent pipeline scaffold
only (no application code). No audit required.

## Success criteria

v1 is successful when Travis can add a valid markdown file to the repo,
push it, and see that post (or tool/comparison page) live on the CloudFront
URL after the deploy pipeline finishes — without a CMS UI and without
manual server steps.

Supporting bar: posts/tools/comparisons render, tags/categories work,
search finds them, RSS includes posts, layout is usable on mobile and
desktop.

A first batch of real editorial content is **not** required to call v1
done; proving the machine is.

## Maintenance plan

Travis owns and operates the site indefinitely. No client handoff. No
retainer. Hosting stays on his AWS account.

## Open items

- Custom domain — **TBD (accepted by Travis)**; use CloudFront default until then
  (later candidates: theagenttoolchain.com / .dev, agenttoolchain.dev)
- Exact static-search library (Pagefind vs similar) — **TBD**, to be chosen
  at implementation; constraint is on-site/static, no hosted search vendor
- AWS OIDC role + GitHub Actions deploy wiring — Travis performs account-side
  setup at bootstrap/deploy; not a product unknown

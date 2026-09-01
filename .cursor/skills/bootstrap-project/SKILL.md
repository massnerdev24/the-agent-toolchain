---
name: bootstrap-project
description: Set up a new repo from the approved Project Brief — generate the stack-specific ci.yml, complete AGENTS.md, and run the GitHub setup script (labels, secrets, branch protection, workflow permissions). Use when asked to "bootstrap", "set up the repo", "wire up CI", or after a project brief is approved.
---

# Bootstrap the repo from the Project Brief

Runs AFTER `docs/PROJECT-BRIEF.md` is APPROVED and BEFORE `build-backlog`.
Turns the brief's technical decisions into working repo configuration.

## Steps
1. Read `docs/PROJECT-BRIEF.md` (stop if status is not APPROVED). Extract:
   stack, platform, hosting, project type (greenfield/existing).
   If `Type:` is EXISTING-CODE, also require `docs/audit/AUDIT-*.md` to exist
   and stop if it does not: the audit's install/test precautions must have
   been applied before this skill runs anything from the repo.
2. **Generate `.github/workflows/ci.yml`:** pick the closest template from
   this skill's `ci-templates/` directory (node / python / flutter), copy it
   over the placeholder ci.yml, then adapt: exact package-manager commands,
   language versions from the brief or repo files, and remove *steps* that
   don't apply. Never remove or rename the `checks` and `security` jobs:
   branch protection requires both by name, and a PR can never merge if
   either stops reporting. If a job has no applicable steps, keep it with a
   single `run: echo "n/a for this stack"`. If the repo already has code (EXISTING-CODE), inspect
   package.json / pyproject.toml / pubspec.yaml and use the project's real
   script names — never guess.
3. **Generate `.cursor/environment.json`** for Background Agents: set the
   install command (and any needed terminals) for the chosen stack —
   node: `npm ci` · python: `pip install uv && uv sync` ·
   flutter: `flutter pub get`. Background agents run in a fresh cloud VM
   that clones the repo; this file is the ONLY way they get dependencies.
   Its commands must be identical to AGENTS.md and ci.yml.
2a. **EXISTING-CODE only — dispose of quarantined client config.** For each
    `<name>.client-untrusted` path the audit inventoried: if the audit's
    Security pass marked it clean, restore the original name; otherwise
    leave it renamed. Either way, list every path and its disposition in
    the bootstrap PR under "## Client config quarantined". Never commit a
    `.client-untrusted` path silently, and never move client workflows
    back into `.github/workflows/` until Travis has read each one.
3b. **Write `.cursor/massner.env`** containing `MASSNER_TEST_CMD="<exact test
    command from AGENTS.md>"`. The stop hook reads it; without it the hook
    assumes `npm test` and will block non-Node repos from ever finishing.
    Then force-track it and prove it: `git add -f .cursor/massner.env &&
    git ls-files --error-unmatch .cursor/massner.env`. If the project
    `.gitignore` matches it (`*.env`, `.env*`), add `!.cursor/massner.env`
    directly below that pattern in the same PR. An untracked massner.env
    means every Background Agent VM falls back to `npm test`.
4. **Complete `AGENTS.md`:** fill every remaining `<placeholder>` using the
   brief. The "How to work in this repo" commands MUST match ci.yml exactly
   — these two files disagreeing is the #1 cause of agent confusion.
5. **Verify locally before touching GitHub:** run the install + lint + test
   commands you just wrote. For a greenfield repo with no code yet, scaffold
   the minimal project first (init command for the chosen framework) so CI
   has something real to run against.
   For EXISTING-CODE repos, follow the install rules in `audit-ai-app`
   (`--ignore-scripts` / fresh virtualenv, no `.env` from the repo, read the
   test setup for network or database access first). Re-enable scripts only
   after the audit report says they were reviewed.
6. **Show Travis the plan, then run `scripts/setup.sh`** (requires `gh`
   authenticated). It configures: labels, CURSOR_API_KEY secret, workflow
   PR-creation permission, and branch protection on main. Do not run it
   without showing what it will do first. Run it as
   `MASSNER_GH_HANDLE=<Travis's handle> scripts/setup.sh`. Never ask for or
   paste API keys; secrets are set by Travis directly with `gh secret set`.
7. Report results as a checklist: each item done/failed, plus the remaining
   TRULY manual items:
   - [ ] Generate CURSOR_API_KEY in the Cursor dashboard (human, once per org)
   - [ ] Enable BugBot for this repo in the Cursor dashboard
   - [ ] Confirm hosting account access per the brief
8. **Cross-check the four copies:** confirm the test command in AGENTS.md is
   byte-identical to the one in ci.yml, `.cursor/environment.json` (install
   only), and `MASSNER_TEST_CMD` in `.cursor/massner.env`. Print the four
   lines side by side in the bootstrap PR description.

## Rules
- The bootstrap PR always includes `docs/PROJECT-BRIEF.md` (Status:
  APPROVED) and, for EXISTING-CODE, `docs/audit/AUDIT-*.md`. Background
  Agents clone from git: a brief that exists only on a workstation is
  invisible to them, and step 1 will stop.
- Never invent script names — if package.json lacks a `lint` script, add the
  script (and its dev dependency) rather than referencing a ghost command.
- Commit generated config via a normal PR (`chore(repo): bootstrap from
  brief`). The ONLY exception: a repo with zero commits (`git rev-list
  --count HEAD` fails). Then push one initial commit containing only
  `README.md`, `AGENTS.md`, `.gitignore` to main, run `scripts/setup.sh`
  (protection needs the branch to exist), and put everything else on the PR.

## Handoff
When CI is green on the bootstrap PR and setup.sh has run, invoke
`build-backlog`.

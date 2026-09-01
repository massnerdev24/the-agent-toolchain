#!/usr/bin/env bash
# Massner repo setup — run once per repo, from the repo root.
# Requires: gh CLI, authenticated with admin rights on the repo.
# NOTE: gh/GitHub API shapes change occasionally; if a step fails, the
# equivalent UI setting is named in the echo line.
set -uo pipefail

REPO=$(gh repo view --json nameWithOwner -q .nameWithOwner) || {
  echo "ERROR: run inside a repo directory with gh authenticated"; exit 1; }
echo "Setting up: $REPO"
FAIL=0
step() { echo; echo "==> $1"; }
ok()   { echo "    ✔ $1"; }
bad()  { echo "    ✘ $1  (do manually in GitHub UI)"; FAIL=1; }

step "Labels"
for L in "agent:spec" "stage:spec" "stage:plan" "stage:implementation" \
         "size:S" "size:M" "size:L"; do
  gh label create "$L" --force >/dev/null 2>&1 && ok "$L" || bad "label $L"
done

step "CODEOWNERS (code-owner review required for merge)"
mkdir -p .github
if [ -f .github/CODEOWNERS ]; then ok "already present"
elif [ -n "${MASSNER_GH_HANDLE:-}" ]; then
  echo "* @${MASSNER_GH_HANDLE}" > .github/CODEOWNERS && ok "created — commit it with the bootstrap PR"
else
  bad "CODEOWNERS — rerun with MASSNER_GH_HANDLE=<you> or create .github/CODEOWNERS with '* @<you>'"
fi

step "Secret: CURSOR_API_KEY"
if gh secret list | grep -q CURSOR_API_KEY; then ok "already set"
else bad "not set — run yourself, never via an agent:  gh secret set CURSOR_API_KEY  (paste from the Cursor dashboard)"
fi

step "Secret: MASSNER_BOT_TOKEN (bot identity that authors agent PRs)"
if gh secret list | grep -q MASSNER_BOT_TOKEN; then
  ok "already set"
else
  bad "not set — create a fine-grained PAT on the massner-bot account (contents:write, pull_requests:write, issues:read), then: gh secret set MASSNER_BOT_TOKEN"
fi

step "Workflow token permissions (write, but NOT approve — agent PRs use MASSNER_BOT_TOKEN)"
gh api -X PUT "repos/$REPO/actions/permissions/workflow" \
  -f default_workflow_permissions=write \
  -F can_approve_pull_request_reviews=false >/dev/null 2>&1 \
  && ok "set" \
  || bad "Settings → Actions → General → Workflow permissions"

# NOTE: enforce_admins=true + code-owner review means a bot approval can
# never satisfy the merge gate, and even an admin token cannot bypass it.
# Solo-dev trade-off: GitHub forbids approving your OWN PRs, so PRs YOU
# author (rare in this pipeline — agents author, you approve) will need the
# protection temporarily relaxed or a second account. Agent-authored PRs are
# unaffected: you are the code owner approving them.
step "Branch protection on main (PRs, CI, 1 code-owner approval, admins enforced)"
gh api -X PUT "repos/$REPO/branches/main/protection" \
  --input - >/dev/null 2>&1 << 'JSON' \
  && ok "protected" \
  || bad "Settings → Branches (note: may require repo to be public or a paid plan on private repos)"
{
  "required_status_checks": { "strict": true, "contexts": ["checks", "security"] },
  "enforce_admins": true,
  "required_pull_request_reviews": {
    "required_approving_review_count": 1,
    "require_code_owner_reviews": true,
    "dismiss_stale_reviews": true
  },
  "restrictions": null,
  "allow_force_pushes": false,
  "allow_deletions": false
}
JSON

echo
echo "Remaining manual (Cursor dashboard): generate API key (once), enable BugBot for $REPO."
[ $FAIL -eq 0 ] && echo "All scriptable steps completed." || echo "Some steps need manual follow-up (marked ✘)."

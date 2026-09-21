#!/usr/bin/env bash
# Trigger the validation workflow and print a timeline of the run, the runner pods and the node count.
. "$(dirname "$0")/common.sh"; need gh; need kubectl
bold ">> gh workflow run arc-automatic-validation.yml --repo $GITHUB_OWNER/$GITHUB_REPO --ref $GITHUB_BRANCH"
gh workflow run arc-automatic-validation.yml --repo "$GITHUB_OWNER/$GITHUB_REPO" --ref "$GITHUB_BRANCH"
sleep 8
RUN=$(gh run list --repo "$GITHUB_OWNER/$GITHUB_REPO" --workflow arc-automatic-validation.yml --limit 1 --json databaseId -q '.[0].databaseId')
echo "   run id $RUN  https://github.com/$GITHUB_OWNER/$GITHUB_REPO/actions/runs/$RUN"
bold ">> timeline (every 10s): run status | runner pods | nodes"
T0=$(date +%s)
for i in $(seq 1 60); do
  st=$(gh run view "$RUN" --repo "$GITHUB_OWNER/$GITHUB_REPO" --json status,conclusion -q '"\(.status) \(.conclusion // "")"')
  pods=$(kubectl -n "$ARC_RUNNERS_NAMESPACE" get pods --no-headers 2>/dev/null | awk '{print $1":"$3}' | tr '\n' ' ')
  nodes=$(kubectl get nodes --no-headers 2>/dev/null | wc -l | tr -d ' ')
  printf 't+%-4ss run=%-20s nodes=%s  pods=[%s]\n' "$(( $(date +%s)-T0 ))" "$st" "$nodes" "$pods" | tee -a "$OUT/timeline.txt"
  case "$st" in completed*) break;; esac; sleep 10
done
bold ">> gh run view $RUN"; gh run view "$RUN" --repo "$GITHUB_OWNER/$GITHUB_REPO"
bold ">> job log (trimmed)"; gh run view "$RUN" --repo "$GITHUB_OWNER/$GITHUB_REPO" --log | cut -f3- | grep -E "runner version|Runner name|ARC runner|^Linux|Docker version|Validation complete"
bold ">> what node auto-provisioning did"; kubectl get nodeclaims 2>/dev/null || true
kubectl get events -A --sort-by=.lastTimestamp 2>/dev/null | grep -Ei "nodeclaim|Nominated|Consolidat" | tail -6 | awk '{$1=$1};1' | cut -c1-170

#!/usr/bin/env bash
# Store the GitHub token and install a runner scale set that registers against your fork.
. "$(dirname "$0")/common.sh"; need helm; need kubectl; need envsubst
: "${GITHUB_TOKEN:?export GITHUB_TOKEN=<PAT with repo scope> first (or: export GITHUB_TOKEN=\$(gh auth token))}"
kubectl create namespace "$ARC_RUNNERS_NAMESPACE" --dry-run=client -o yaml | kubectl apply -f -
printf '%s' "$GITHUB_TOKEN" | kubectl create secret generic github-pat --namespace "$ARC_RUNNERS_NAMESPACE" \
  --from-file=github_token=/dev/stdin --dry-run=client -o yaml | kubectl apply -f -
bold ">> helm install gha-runner-scale-set '$RUNNER_SET_NAME' for $GITHUB_CONFIG_URL"
envsubst '${GITHUB_CONFIG_URL}' < "$ROOT/k8s/arc-runner-set-values.yaml" \
  | helm upgrade --install "$RUNNER_SET_NAME" \
      oci://ghcr.io/actions/actions-runner-controller-charts/gha-runner-scale-set \
      --namespace "$ARC_RUNNERS_NAMESPACE" --wait --timeout 10m -f - 2>&1 | grep -v "^Pulled\|^Digest"
bold ">> listener pod (long-polls GitHub for jobs)"
n=0; until kubectl -n "$ARC_SYSTEMS_NAMESPACE" get pods --no-headers | grep -q listener || [ $n -ge 12 ]; do n=$((n+1)); sleep 5; done
kubectl -n "$ARC_SYSTEMS_NAMESPACE" get pods
bold ">> runner set (0 runners at rest is expected: minRunners is 0)"
kubectl -n "$ARC_RUNNERS_NAMESPACE" get autoscalingrunnersets

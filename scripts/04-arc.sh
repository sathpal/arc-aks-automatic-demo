#!/usr/bin/env bash
# Install the Actions Runner Controller. The values file adds resource requests, which Deployment Safeguards require.
. "$(dirname "$0")/common.sh"; need helm; need kubectl
bold ">> helm install gha-runner-scale-set-controller -> $ARC_SYSTEMS_NAMESPACE"
helm upgrade --install arc \
  oci://ghcr.io/actions/actions-runner-controller-charts/gha-runner-scale-set-controller \
  --namespace "$ARC_SYSTEMS_NAMESPACE" --create-namespace --wait --timeout 10m \
  -f "$ROOT/k8s/arc-controller-values.yaml" 2>&1 | tee "$OUT/arc-install.log" | grep -v "^Pulled\|^Digest"
bold ">> Deployment Safeguards warnings from that install (warn level, install still succeeds)"
grep -o 'Warning: .*' "$OUT/arc-install.log" | sed 's/\\"/"/g' | cut -c1-200 || echo "   none"
bold ">> kubectl -n $ARC_SYSTEMS_NAMESPACE get pods"; kubectl -n "$ARC_SYSTEMS_NAMESPACE" get pods

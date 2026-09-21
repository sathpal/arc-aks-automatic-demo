#!/usr/bin/env bash
# One screen: cluster, ARC pods, runner set, node claims.
. "$(dirname "$0")/common.sh"; need kubectl
bold ">> nodes"; kubectl get nodes
bold ">> node claims (Karpenter)"; kubectl get nodeclaims 2>/dev/null || echo "   none"
bold ">> ARC"; kubectl -n "$ARC_SYSTEMS_NAMESPACE" get pods; kubectl -n "$ARC_RUNNERS_NAMESPACE" get autoscalingrunnersets,pods 2>/dev/null

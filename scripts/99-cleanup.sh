#!/usr/bin/env bash
# Remove ARC, then delete the resource group (which also removes the node resource group AKS created).
. "$(dirname "$0")/common.sh"
helm uninstall "$RUNNER_SET_NAME" -n "$ARC_RUNNERS_NAMESPACE" 2>/dev/null || true
helm uninstall arc -n "$ARC_SYSTEMS_NAMESPACE" 2>/dev/null || true
kubectl delete namespace "$ARC_RUNNERS_NAMESPACE" "$ARC_SYSTEMS_NAMESPACE" --ignore-not-found --timeout=120s || true
bold ">> az group delete $RG (runs in the background; billing stops when it finishes)"
az group delete --name "$RG" --yes --no-wait
kubectl config delete-context "$CLUSTER" 2>/dev/null || true

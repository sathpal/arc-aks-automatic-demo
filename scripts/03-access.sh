#!/usr/bin/env bash
# Local accounts are disabled on AKS Automatic: grant yourself Kubernetes RBAC through Azure, then use kubelogin.
. "$(dirname "$0")/common.sh"; need az; need kubectl; need kubelogin
AKS_ID=$(az aks show -g "$RG" -n "$CLUSTER" --query id -o tsv)
ME=$(az ad signed-in-user show --query id -o tsv)
bold ">> az role assignment create: Azure Kubernetes Service RBAC Cluster Admin -> you"
az role assignment create --assignee "$ME" --role "Azure Kubernetes Service RBAC Cluster Admin" --scope "$AKS_ID" -o none 2>/dev/null || echo "   (already assigned)"
az aks get-credentials -g "$RG" -n "$CLUSTER" --format exec --overwrite-existing
bold ">> waiting for the role to propagate"
n=0; until kubectl get nodes >/dev/null 2>&1 || [ $n -ge 30 ]; do n=$((n+1)); sleep 10; done
bold ">> kubectl get nodes -o wide"; kubectl get nodes -o wide

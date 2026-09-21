#!/usr/bin/env bash
# Install or upgrade the CLIs. The Azure CLI must be recent: --sku automatic needs 2.80 or newer.
set -euo pipefail
brew list azure-cli >/dev/null 2>&1 && brew upgrade azure-cli || brew install azure-cli
for t in kubectl helm gh; do command -v $t >/dev/null || brew install $t; done
command -v kubelogin >/dev/null || brew install Azure/kubelogin/kubelogin
az extension add -n quota -y >/dev/null 2>&1 || true
echo "az $(az version --query '"azure-cli"' -o tsv)  |  $(kubectl version --client -o yaml | grep gitVersion | head -1)  |  $(helm version --short)  |  gh $(gh --version | head -1 | awk '{print $3}')"
echo "note: do NOT add the aks-preview extension; the automatic SKU is in the core CLI and the preview can break older CLIs."

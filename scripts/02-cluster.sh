#!/usr/bin/env bash
# Create the resource group and the AKS Automatic cluster. Takes 20 to 35 minutes.
. "$(dirname "$0")/common.sh"; need az
bold ">> az account show"; az account show --query '{subscription:name, id:id}' -o table
az group create --name "$RG" --location "$LOCATION" -o none
bold ">> az aks create --sku automatic  (this is the long step)"
time az aks create --resource-group "$RG" --name "$CLUSTER" --location "$LOCATION" --sku automatic --no-ssh-key -o none
bold ">> cluster profile"
az aks show -g "$RG" -n "$CLUSTER" --query "{sku:sku.name, kubernetes:currentKubernetesVersion, nodeProvisioning:nodeProvisioningProfile.mode, azureRbac:aadProfile.enableAzureRbac, localAccountsDisabled:disableLocalAccounts, state:provisioningState}" -o yaml

#!/usr/bin/env bash
# AKS Automatic needs 16 vCPUs of quota in ONE of the D4 families it accepts. Default subscriptions have 10.
. "$(dirname "$0")/common.sh"; need az
SUB=$(az account show --query id -o tsv)
SCOPE="/subscriptions/$SUB/providers/Microsoft.Compute/locations/$LOCATION"
bold ">> subscription: $(az account show --query name -o tsv)   region: $LOCATION"
bold ">> current D-family quotas with a limit above 10 (empty means you need an increase)"
az vm list-usage -l "$LOCATION" -o tsv --query "[?contains(name.value,'standardD')].[name.value,currentValue,limit]" | awk -F'\t' '$3>10{printf "   %-32s %s/%s\n",$1,$2,$3}'
bold ">> requesting $QUOTA_CORES cores for $QUOTA_FAMILY in $LOCATION"
az quota update --resource-name "$QUOTA_FAMILY" --scope "$SCOPE" --limit-object value="$QUOTA_CORES" --resource-type dedicated -o none \
  && echo "   approved: $(az vm list-usage -l "$LOCATION" -o tsv --query "[?name.value=='$QUOTA_FAMILY'].limit") cores" \
  || echo "   refused (ContactSupport). Try another family from the list in the README, or open a support request."

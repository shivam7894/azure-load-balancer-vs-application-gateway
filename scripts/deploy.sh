#!/usr/bin/env bash
set -euo pipefail
RG="${1:-rg-lb-agw-real-demo}"
LOCATION="${2:-eastus}"

az group create --name "$RG" --location "$LOCATION"

read -s -p "VM admin password: " PASSWORD
echo

az deployment group create \
  --resource-group "$RG" \
  --template-file ./infra/main.bicep \
  --parameters location="$LOCATION" adminUsername=azureuser adminPassword="$PASSWORD"

unset PASSWORD

az deployment group show \
  --resource-group "$RG" \
  --name main \
  --query properties.outputs

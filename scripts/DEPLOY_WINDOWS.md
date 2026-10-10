# REAL AZURE DEPLOYMENT — PowerShell

## Prerequisites
- Azure subscription
- Azure CLI installed
- An Azure region available to your subscription
- Permission to create resource groups/network/compute resources
- Expect charges while resources exist

## 1. Login
az login
az account show

## 2. Create resource group
$RG="rg-lb-agw-real-demo"
$LOCATION="eastus"

az group create --name $RG --location $LOCATION

## 3. Deploy the complete infrastructure
$PASSWORD = Read-Host "Enter a strong VM admin password" -AsSecureString
# Convert SecureString for Bicep parameter file at the shell boundary:
$plain = [Runtime.InteropServices.Marshal]::PtrToStringAuto([Runtime.InteropServices.Marshal]::SecureStringToBSTR($PASSWORD))

az deployment group create `
  --resource-group $RG `
  --template-file .\infra\main.bicep `
  --parameters location=$LOCATION adminUsername=azureuser adminPassword=$plain

Remove-Variable plain

## 4. Get the outputs
az deployment group show `
  --resource-group $RG `
  --name main `
  --query properties.outputs

Or:
az network public-ip show -g $RG -n pip-lb --query ipAddress -o tsv
az network public-ip show -g $RG -n pip-agw --query ipAddress -o tsv

## 5. Test Load Balancer
$LBIP = az network public-ip show -g $RG -n pip-lb --query ipAddress -o tsv
curl.exe "http://$LBIP/"
curl.exe "http://$LBIP/health"

Refresh the LB endpoint multiple times. The response should show the backend hostname. With multiple backend VMs, the frontend distributes eligible new flows across healthy instances.

## 6. Test Application Gateway
$AGWIP = az network public-ip show -g $RG -n pip-agw --query ipAddress -o tsv

curl.exe "http://$AGWIP/products"
curl.exe "http://$AGWIP/orders"

Expected:
- /products -> product-service on backend port 8081
- /orders -> order-service on backend port 8082

The Application Gateway path map makes the routing decision based on the URL path.

## 7. Verify health
az network application-gateway show `
  -g $RG `
  -n agw-standard-v2-demo `
  --query "backendAddressPools[].{name:name,addresses:backendAddresses}" `
  -o table

az network application-gateway show-backend-health `
  -g $RG `
  -n agw-standard-v2-demo `
  -o json

## 8. Faculty screenshots
Take screenshots of:
1. Resource group
2. VNet/subnets
3. Load Balancer Overview
4. LB frontend IP
5. LB backend pool
6. LB health probe
7. LB rule
8. Application Gateway Overview
9. AGW frontend IP
10. AGW backend pools
11. AGW listener
12. AGW path-based rule
13. AGW backend health
14. Browser/Postman /products
15. Browser/Postman /orders

## 9. Optional failure demonstration
Stop one VM:
az vm stop -g $RG -n vm-backend-01

Wait for health state to update, then repeat tests.

Start it again:
az vm start -g $RG -n vm-backend-01

## 10. CLEANUP — VERY IMPORTANT
When the demo is finished:
az group delete --name $RG --yes --no-wait

This removes the resource group and its resources. Confirm in the Azure portal that resources are deleted.


## Important for this fixed package

Run the validation command before the real deployment. The backend VM IPs are static,
and the Application Gateway subnet is intentionally left without an NSG for this
small lab so the gateway's required infrastructure traffic is not accidentally blocked.

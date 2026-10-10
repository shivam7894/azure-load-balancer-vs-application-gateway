# Part 4 — Deployment and Testing

## 4.1 Before you start

This deployment can incur Azure charges. Review the current pricing for the selected region, VM size, public IPs, and Application Gateway SKU. Use a dedicated resource group containing only this lab.

Required tools:

- Azure CLI
- PowerShell on Windows
- A valid Azure subscription
- Permissions to create the resources in the template

## 4.2 Sign in and select a subscription

```powershell
az login
az account show
```

If multiple subscriptions are available, select the intended one:

```powershell
az account set --subscription "<YOUR_SUBSCRIPTION_NAME_OR_ID>"
```

Do not put your subscription ID or personal account details into public screenshots unless there is a specific reason and they are appropriately redacted.

## 4.3 Validate and deploy

From the project root:

```powershell
az bicep build --file .\infra\main.bicep

$RG = "rg-lb-agw-real-demo"
$LOCATION = "eastus"

az group create --name $RG --location $LOCATION
```

Then follow the full parameter handling and deployment instructions in [`../scripts/DEPLOY_WINDOWS.md`](../scripts/DEPLOY_WINDOWS.md). Use a strong unique password. Do not commit it to Git.

Check deployment state:

```powershell
az deployment group show `
  --resource-group $RG `
  --name main `
  --query properties.provisioningState `
  -o tsv
```

If the deployment reports failure, inspect the operations:

```powershell
az deployment operation group list `
  --resource-group $RG `
  --name main `
  -o table
```

Do not continue to functional tests until the deployment is successful and backend services have had time to initialize.

## 4.4 Retrieve public IPs

```powershell
$LBIP = az network public-ip show -g $RG -n pip-lb --query ipAddress -o tsv
$AGWIP = az network public-ip show -g $RG -n pip-agw --query ipAddress -o tsv

Write-Host "Load Balancer IP: $LBIP"
Write-Host "Application Gateway IP: $AGWIP"
```

## 4.5 Test cases

| ID | Test | Command | Expected result |
|---|---|---|---|
| TC-01 | Load Balancer landing page | `curl.exe "http://$LBIP/"` | Nginx HTML showing backend hostname |
| TC-02 | Load Balancer health path | `curl.exe "http://$LBIP/health"` | `UP` |
| TC-03 | Product path routing | `curl.exe "http://$AGWIP/products"` | JSON with `role` set to `product-service` and port 8081 |
| TC-04 | Order path routing | `curl.exe "http://$AGWIP/orders"` | JSON with `role` set to `order-service` and port 8082 |
| TC-05 | Application Gateway backend health | Azure CLI command below | Backend health entries should indicate healthy after services and probes are ready |

Run the endpoint tests:

```powershell
curl.exe "http://$LBIP/"
curl.exe "http://$LBIP/health"
curl.exe "http://$AGWIP/products"
curl.exe "http://$AGWIP/orders"
```

Check Application Gateway backend health:

```powershell
az network application-gateway show-backend-health `
  --resource-group $RG `
  --name agw-standard-v2-demo `
  -o json
```

**Important:** The table describes expected behavior. In the report, record the actual HTTP response, date/time, and result (Pass/Fail). Do not mark a test as passed unless you ran it.

## 4.6 Troubleshooting guide

### Public endpoint does not respond

- Confirm deployment state and public IP assignment.
- Confirm Application Gateway provisioning has completed.
- Check the backend health status.
- Review NSG rules and backend port settings.
- Wait for cloud-init and systemd services to finish starting.
- Review the Azure deployment operations for resource failures.

### `/products` or `/orders` fails

- Confirm the correct Application Gateway public IP is used.
- Check the path map and backend HTTP settings.
- Verify backend pools point to the intended private IPs.
- Confirm service ports 8081 and 8082 are listening on the VMs.
- Check the Application Gateway backend health output and probe configuration.

### Backend health is unhealthy

- Verify the application service is running.
- Check the probe path, port, protocol, and host settings.
- Check NSG rules permit the required gateway-to-backend traffic.
- Review cloud-init output on the VM and systemd service status.

### Deployment fails

- Validate Bicep syntax.
- Confirm region/SKU availability and subscription quotas.
- Read the first meaningful deployment error and address it before retrying.
- Avoid repeated deployments without understanding the failure.

## 4.7 Evidence and screenshot checklist

Capture your own screenshots after deployment:

1. Azure resource group with the lab resources.
2. Virtual network and subnet configuration.
3. Load Balancer overview and frontend IP.
4. Load Balancer backend pool, probe, and rule.
5. Application Gateway overview and frontend IP.
6. Application Gateway backend pools, listener, and path map.
7. Application Gateway backend health.
8. Terminal or browser output for `/`, `/health`, `/products`, and `/orders`.

Redact subscription identifiers and personal information if screenshots will be public. Never use fabricated screenshots or claim an expected output is observed evidence.

## 4.8 Optional failure demonstration

For a controlled learning exercise, stop one backend VM and observe how health state and requests change. Only do this in the disposable lab, and start the VM again afterward. The timing of probe state changes is not instantaneous.

## 4.9 Cleanup

When evidence collection is complete:

```powershell
az group delete --name $RG --yes --no-wait
```

Wait for deletion to finish and verify in the Azure portal or run:

```powershell
az group exists --name $RG
```

The expected result after completion is `false`. Make sure the resource group contains only this project before deleting it.

## 4.10 Test report template

Fill this in with actual observations:

| Test ID | Actual output / observation | Pass/Fail | Evidence file |
|---|---|---|---|
| TC-01 | _Add actual output_ | _Not run_ | _Add screenshot name_ |
| TC-02 | _Add actual output_ | _Not run_ | _Add screenshot name_ |
| TC-03 | _Add actual output_ | _Not run_ | _Add screenshot name_ |
| TC-04 | _Add actual output_ | _Not run_ | _Add screenshot name_ |
| TC-05 | _Add actual health status_ | _Not run_ | _Add screenshot name_ |

## 4.11 Part 4 summary

The deployment is complete only when the infrastructure succeeds and the test results are verified. Capture evidence, document any failures and fixes, and delete the resource group when finished.

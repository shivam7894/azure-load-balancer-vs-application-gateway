# Azure Load Balancer vs Application Gateway — Implementation Report

> Complete the status, screenshots, dates, and measured outputs only after running the deployment in your own Azure subscription.

## Project details

- **Project title:** Azure Load Balancer vs Application Gateway
- **Platform:** Microsoft Azure
- **Infrastructure definition:** Azure Bicep
- **Backend:** Ubuntu, Nginx, Python 3
- **Deployment status:** _Not recorded — update after deployment_
- **Deployment date/time:** _Fill in_
- **Azure region:** _Fill in_
- **Resource group:** `rg-lb-agw-real-demo`

## 1. Introduction

The project compares Layer 4 TCP flow distribution with Layer 7 HTTP URL path-based routing using Azure's Load Balancer and Application Gateway.

## 2. Problem statement

A single backend can become a bottleneck or failure point, and multi-service web applications may need URL-based routing. The project provides a repeatable lab to demonstrate these requirements.

## 3. Implementation summary

The Bicep template is designed to create a virtual network, subnets, two Ubuntu VMs, NSG rules, public IPs, a Standard Load Balancer, and an Application Gateway Standard_v2. Cloud-init installs Nginx and creates the demo product and order services.

## 4. Architecture

See [`ARCHITECTURE.md`](ARCHITECTURE.md) and [`02-abstraction-architecture.md`](02-abstraction-architecture.md).

## 5. Deployment procedure

Follow [`scripts/DEPLOY_WINDOWS.md`](../scripts/DEPLOY_WINDOWS.md). Record the deployment command, region, resource group, provisioning result, and any fixes made. Do not include credentials in the report.

## 6. Test results

| Test | Expected result | Actual result | Status |
|---|---|---|---|
| Load Balancer `/` | Nginx page / backend hostname | _Fill in_ | _Not run_ |
| Load Balancer `/health` | `UP` | _Fill in_ | _Not run_ |
| Application Gateway `/products` | Product service JSON | _Fill in_ | _Not run_ |
| Application Gateway `/orders` | Order service JSON | _Fill in_ | _Not run_ |
| Application Gateway backend health | Healthy backend entries | _Fill in_ | _Not run_ |

## 7. Evidence

Add genuine screenshots to a repository folder such as `docs/images/` after deployment. Suggested evidence:

- Resource group and VNet/subnets
- Load Balancer frontend, backend pool, probe, and rule
- Application Gateway listener, backend pools, path map, and backend health
- Terminal/browser outputs for all test cases

Redact sensitive identifiers and never include passwords or keys.

## 8. Cost and cleanup

Azure networking and compute resources can incur charges. After evidence collection, delete the dedicated lab resource group and confirm deletion in the Azure portal or with Azure CLI.

## 9. Conclusion

The lab is designed to demonstrate the difference between Layer 4 load balancing and Layer 7 URL path routing. Complete this report with real results before submitting it as an implementation report.

# Part 3 — Implementation and Code Walkthrough

## 3.1 Infrastructure as code

The file `infra/main.bicep` defines the Azure resources declaratively. Bicep is compiled to an ARM deployment template and submitted through Azure Resource Manager. This makes the infrastructure reviewable and repeatable.

Before deploying, inspect the complete template and run:

```powershell
az bicep build --file .\infra\main.bicep
```

A successful build validates Bicep syntax, but it does not guarantee that every resource is available, permitted, or successfully provisioned in a particular subscription and region.

## 3.2 Parameterization

The template defines values such as:

- `location`: defaults to the resource group's region.
- `adminUsername`: VM administrator name.
- `adminPassword`: secure parameter for the VM password.
- `vmSize`: VM SKU used by the template.

Keep secrets out of source control. Do not replace secure parameters with hard-coded passwords. Use a unique lab password and follow your organization's secret-handling guidance.

## 3.3 Network design

The lab uses a virtual network with address space `10.20.0.0/16` and two subnets:

- Backend subnet: `10.20.1.0/24`
- Application Gateway subnet: `10.20.2.0/24`

The Application Gateway uses a dedicated subnet. Backend VM NICs use private addresses defined in the Bicep template so the gateway backend configuration can refer to predictable addresses.

Network Security Group rules are intended to permit the traffic required by the demo while limiting unnecessary inbound access. Review every rule before using this template beyond a disposable lab.

## 3.4 Load Balancer resources

The Bicep template creates a Standard public IP and a Standard Azure Load Balancer. Its relevant configuration includes:

- Frontend IP configuration associated with the public IP.
- Backend address pool containing the backend NICs.
- HTTP health probe using port 80 and path `/health`.
- TCP load-balancing rule from frontend port 80 to backend port 80.

The health probe helps the Load Balancer identify eligible backend instances. Probe success does not by itself prove that every application feature is functioning correctly.

## 3.5 Application Gateway resources

The template defines an Application Gateway Standard_v2 resource with:

- Standard public IP frontend.
- HTTP frontend port 80.
- HTTP listener.
- Product and order backend address pools.
- Backend HTTP settings using ports 8081 and 8082.
- Health probes for the backend services.
- URL path map and path-based routing rule.

The path rules are designed to route `/products` and `/products/*` to the product backend, and `/orders` and `/orders/*` to the order backend. The default path is configured in the Bicep template; inspect that choice and change it if your use case requires a different default.

## 3.6 Backend bootstrap: `backend/cloud-init.sh`

The cloud-init script runs when a VM is provisioned. Its responsibilities are:

1. Update the Ubuntu package index.
2. Install Nginx and Python 3.
3. Write an Nginx landing page showing the VM hostname.
4. Write a small Python HTTP server that returns JSON.
5. Create systemd units for the product service on port 8081 and order service on port 8082.
6. Create a `/health` file for the Nginx endpoint.
7. Enable and start the services.

### Simplified Python service logic

The actual service implementation is written by `cloud-init.sh`. Its core behavior can be summarized as:

```python
body = {
    "status": "UP",
    "backend": os.uname().nodename,
    "role": role,
    "port": port,
    "path": self.path
}
```

The response helps identify which backend service handled the request. It is diagnostic demo output and should not be treated as a secure production API.

## 3.7 Deployment scripts

### `scripts/DEPLOY_WINDOWS.md`

Provides PowerShell commands for signing in, creating the resource group, deploying Bicep, retrieving public IPs, testing the endpoints, checking Application Gateway health, and deleting the lab.

### `scripts/deploy.sh`

Provides a Bash-based deployment route for users with Azure CLI and a compatible shell. Review the script and run it from the project root.

### `scripts/cleanup.ps1`

Requests deletion of the specified resource group. Use it only when the resource group contains the disposable lab resources and nothing unrelated.

## 3.8 Resource dependency and provisioning notes

Azure resources have dependencies: the virtual network and subnets must be available to the VM NICs and gateway; the public IPs and backend pools must be referenced correctly by the traffic management resources. Bicep resource references can establish deployment dependencies, but runtime readiness (such as cloud-init finishing and application health) can take longer than infrastructure provisioning.

If deployment fails:

1. Read the first meaningful error from the Azure deployment operation.
2. Confirm the selected region supports the chosen SKU and VM size.
3. Check subscription quotas and resource-provider registration.
4. Check Bicep compilation and parameter names.
5. Verify that cloud-init completed and services are listening.
6. Re-check NSG rules, backend IPs, probes, and backend health.

## 3.9 Security review checklist

- [ ] No passwords, access tokens, private keys, or credentials are committed.
- [ ] VM SSH is not exposed broadly to the Internet.
- [ ] Only required inbound ports are allowed.
- [ ] HTTP-only limitations are clearly documented.
- [ ] No production or personal data is used.
- [ ] Screenshots do not expose subscription IDs, credentials, or other sensitive details.

## 3.10 Part 3 summary

The infrastructure template defines Azure networking and routing, while cloud-init configures the VM applications. The scripts provide a repeatable path to deployment and cleanup. Part 4 covers the actual runbook and test evidence.

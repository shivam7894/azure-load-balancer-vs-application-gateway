# Part 1 — Introduction and Problem Statement

## 1.1 Introduction

Cloud applications need reliable ways to accept user traffic and deliver it to application servers. As request volume grows, a single server can become a bottleneck. A server failure can also make an application unavailable if there is no alternate backend.

Microsoft Azure offers different traffic distribution services. Azure Load Balancer operates at Layer 4 and distributes TCP/UDP flows. Azure Application Gateway operates at Layer 7 and understands HTTP requests, allowing features such as URL path-based routing.

This project demonstrates the difference through a small, repeatable lab using Azure Bicep, two Ubuntu virtual machines, Nginx, and Python HTTP endpoints.

## 1.2 Problem statement

A single backend server can be overloaded or become unavailable. A multi-service web application may also need to send requests such as `/products` and `/orders` to different services. A basic network load balancer distributes connections but does not make routing decisions based on URL paths.

The problem is to design and implement a cloud lab that demonstrates both network-level traffic distribution and application-aware HTTP routing, while documenting the configuration and validation process.

## 1.3 Proposed solution

The lab deploys two Azure entry points:

1. A Standard Azure Load Balancer with a TCP port 80 rule and health probe. It distributes eligible flows to healthy backend VM instances.
2. An Application Gateway Standard_v2 instance with an HTTP listener and path map. It routes `/products` to a backend service on port 8081 and `/orders` to a backend service on port 8082.

Both demonstrations share the same backend VMs to reduce lab complexity and resource count.

## 1.4 Objectives

- Explain Layer 4 and Layer 7 traffic management.
- Create the required virtual network and subnets.
- Provision and configure two Ubuntu backend VMs.
- Create health probes and backend pools.
- Configure URL path routing.
- Deploy using declarative Azure Bicep.
- Validate endpoints and record real evidence.
- Document resource cleanup and cost considerations.

## 1.5 Scope

### Included

- Azure networking resources and public entry points.
- Two Ubuntu VMs with Nginx and Python demo services.
- Load Balancer rule and health probe.
- Application Gateway listener, backend pools, backend HTTP settings, probes, and path rules.
- Deployment instructions, test plan, and cleanup procedure.

### Not included

- Production-grade application code.
- HTTPS certificate management.
- Web Application Firewall tuning.
- CI/CD pipeline or automated integration test pipeline.
- High-availability guarantees beyond the limited lab design.
- A cost estimate that is guaranteed for every Azure region or subscription.

## 1.6 Expected outcomes

After a successful deployment, the expected behavior is:

- The Load Balancer endpoint returns an Nginx page from a backend VM.
- `/health` returns `UP` through the Load Balancer.
- Application Gateway routes `/products` to the product demo service.
- Application Gateway routes `/orders` to the order demo service.
- Azure CLI reports the Application Gateway backend health.

These are expected outcomes, not proof of a deployment. Replace them with actual observed results and timestamps in the final report.

## 1.7 Stakeholders and use cases

| Stakeholder | Use |
|---|---|
| Student/developer | Learn Azure networking and infrastructure-as-code |
| Reviewer/faculty | Inspect architecture, code, test plan, and evidence |
| Cloud/DevOps interviewer | Discuss resource provisioning, health checks, routing, and trade-offs |

## 1.8 Part 1 summary

This part defines the problem, proposed solution, objectives, scope, and expected outcomes. Part 2 explains the system abstraction and architecture.

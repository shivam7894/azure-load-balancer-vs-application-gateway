# Part 5 — Results, Limitations and Conclusion

## 5.1 Results to report

The purpose of this lab is to observe two different routing behaviors. After deployment, use actual command output and Azure health information to complete the results table.

| Area | Expected behavior | Actual observation |
|---|---|---|
| Load Balancer `/` | Nginx page from a backend VM | _Fill after testing_ |
| Load Balancer `/health` | `UP` | _Fill after testing_ |
| Application Gateway `/products` | Product service JSON on port 8081 | _Fill after testing_ |
| Application Gateway `/orders` | Order service JSON on port 8082 | _Fill after testing_ |
| Application Gateway health | Configured backends become healthy | _Fill after testing_ |

Do not leave expected behavior presented as measured results. Replace the blank cells only after running the tests.

## 5.2 Comparison and interpretation

The Load Balancer is appropriate when the requirement is network-level distribution of supported TCP/UDP traffic. It does not inspect HTTP URL paths to select application services.

Application Gateway is suitable when web traffic needs Layer 7 capabilities such as URL path-based routing. In this lab, the path map differentiates product and order requests and sends them to backend services on different ports.

The services address different layers and can be used together in larger architectures when the requirements justify it. The correct design depends on application protocols, routing needs, security controls, availability targets, operational complexity, and cost.

## 5.3 Limitations

- The backend services are deliberately small demonstration endpoints.
- The example uses HTTP, not HTTPS.
- No TLS certificate, Web Application Firewall policy, authentication, or production monitoring configuration is included.
- Shared backend VMs simplify the lab but do not represent a complete production deployment.
- The deployment may require adjustments based on region, SKU availability, subscription quotas, Azure policy, or changes to resource APIs.
- Health probes confirm probe responses, not complete end-to-end application correctness.
- Costs vary by region, SKU, uptime, traffic, and current Azure pricing.

## 5.4 Future enhancements

1. Configure HTTPS and certificate management.
2. Add a Web Application Firewall policy and demonstrate its configuration safely.
3. Add monitoring, diagnostic settings, and alerts.
4. Add automated smoke tests and deployment validation.
5. Add CI/CD with approval gates and secure secret management.
6. Store deployment parameters in a non-secret parameter file where appropriate.
7. Extend the comparison to include Application Gateway autoscaling and backend health observations.
8. Add screenshots and measured results from a real deployment.

## 5.5 Conclusion

This project demonstrates the difference between Layer 4 and Layer 7 traffic management in Microsoft Azure. The Standard Load Balancer distributes eligible TCP flows to healthy backend VMs, while Application Gateway uses HTTP path rules to direct `/products` and `/orders` requests to different backend services. Azure Bicep makes the infrastructure declarative and reviewable, and cloud-init configures the demo services during provisioning.

The strongest portfolio submission combines the code with an accurate README, architecture diagrams, deployment instructions, real test evidence, a cost warning, and a verified cleanup process. The project should only be described as deployed and tested after those steps have actually been completed.

## 5.6 Viva/interview questions

1. What is the key difference between Layer 4 and Layer 7 load balancing?
2. Why does the project use an Azure Load Balancer health probe?
3. Why does Application Gateway need backend HTTP settings?
4. How does URL path-based routing work?
5. Why is the Application Gateway placed in a dedicated subnet?
6. What is Azure Bicep, and how does it help with repeatable infrastructure?
7. What is cloud-init used for in this project?
8. How would you secure this architecture for production?
9. How would you diagnose an unhealthy Application Gateway backend?
10. Why should the resource group be deleted after the lab?

## 5.7 Final submission checklist

- [ ] README explains the project and links to all documentation parts.
- [ ] Architecture diagrams match the implementation.
- [ ] Bicep compiles and deployment errors are resolved.
- [ ] Test table is completed with actual results.
- [ ] Screenshots are genuine and do not expose secrets.
- [ ] No passwords, tokens, keys, or other secrets are committed.
- [ ] Cost warning and cleanup instructions are visible.
- [ ] Repository has a clear name and meaningful commit history.

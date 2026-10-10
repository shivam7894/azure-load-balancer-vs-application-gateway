# Upload this project to GitHub (Windows)

## Option A — Upload using the GitHub website

1. Extract the ZIP file.
2. Open GitHub and sign in.
3. Click **+ → New repository**.
4. Name it `azure-load-balancer-vs-application-gateway`.
5. Add a short description and choose Public only if you are comfortable making the code public.
6. Create the repository.
7. Open the extracted project folder. Select the *contents* of `Azure_LoadBalancer_vs_ApplicationGateway_Real_Azure_Project` (README, infra, backend, scripts, docs, and other files), not the outer parent folder.
8. Drag those files/folders into **Add file → Upload files**.
9. Enter a commit message such as `Add Azure load balancing comparison project`.
10. Click **Commit changes**.

If GitHub's web uploader rejects the total size or number of files, use Option B.

## Option B — Upload with Git (recommended)

Install Git for Windows if it is not already installed. Open PowerShell inside the project folder:

```powershell
git init
git add .
git status
```

Review `git status` carefully. Do not continue if credentials, private keys, personal data, or unwanted files are listed.

```powershell
git commit -m "Add Azure load balancing comparison project"
git branch -M main
git remote add origin https://github.com/YOUR-USERNAME/azure-load-balancer-vs-application-gateway.git
git push -u origin main
```

Replace `YOUR-USERNAME` with your GitHub username. If Git says the remote already exists, inspect it with `git remote -v` before changing it. GitHub may ask you to authenticate in a browser or through its supported credential manager.

## Before making the repository public

- Check that no passwords, tokens, keys, or personal information are committed.
- Do not upload Azure portal screenshots containing sensitive identifiers.
- Confirm the README and docs reflect the current code.
- Do not claim the infrastructure was deployed or tested unless you performed those steps.
- After deployment, add genuine screenshots and fill in the test report.
- Delete the Azure resource group after the demo to avoid unnecessary charges.

## Suggested repository description

`Educational Azure project comparing Layer 4 Load Balancer traffic distribution with Layer 7 Application Gateway path-based routing using Bicep.`

## Suggested GitHub topics

`azure`, `azure-bicep`, `cloud-computing`, `devops`, `load-balancer`, `application-gateway`, `infrastructure-as-code`

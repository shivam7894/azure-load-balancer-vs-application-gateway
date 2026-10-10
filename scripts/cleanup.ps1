param(
  [string]$ResourceGroup = "rg-lb-agw-real-demo"
)

az group delete --name $ResourceGroup --yes --no-wait
Write-Host "Deletion requested for $ResourceGroup"

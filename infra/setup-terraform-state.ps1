# Documentation:
# This Powershell script uses Azure CLI to deploy a storage account for the terraform state.
# This script gets executed before Terraform init, plan and apply in the CI/CD pipeline. 

[CmdletBinding()]
param (
    [string]$env,
    [string]$resourceGroupName,
    [string]$storageAccountName,
    [string]$containerName
)

# Vars
$location = "westeurope"

# Create resource group.
if ((az group exists --name $resourceGroupName) -eq 'false') {
    Write-Output "Creating resource group..."
    az group create `
        --location $location `
        --name $resourceGroupName
}

# Create storage account.
if ((az storage account check-name --name $storageAccountName --query 'nameAvailable' --auth-mode login) -eq 'true') {
    Write-Output "Creating storage account..."
    az storage account create `
        --location $location `
        --name $storageAccountName `
        --sku Standard_ZRS `
        --kind StorageV2 `
        --resource-group $resourceGroupName `
        --auth-mode login
}

# Create storage account container for state file.
if ((az storage container exists --account-name $storageAccountName --name $containerName --query 'exists' --auth-mode login) -eq 'false') {
    Write-Output "Creating container..."
    az storage container create `
        --name $containerName `
        --account-name $storageAccountName `
        --auth-mode login
}
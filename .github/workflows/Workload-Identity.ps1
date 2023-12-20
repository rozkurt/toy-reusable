$azureContext = Get-AzContext

$githubOrganizationName = 'rozkurt'
$githubRepositoryName = 'toy-reusable'

# Create a workload identity for your deployments workflow.

$applicationRegistration = New-AzADApplication -DisplayName 'toy-reusable'
New-AzADAppFederatedCredential `
   -Name 'toy-reusable-branch' `
   -ApplicationObjectId $applicationRegistration.Id `
   -Issuer 'https://token.actions.githubusercontent.com' `
   -Audience 'api://AzureADTokenExchange' `
   -Subject "repo:$($githubOrganizationName)/$($githubRepositoryName):ref:refs/heads/main"

# Create a resource group in Azure and grant the workload identity access

$resourceGroup = New-AzResourceGroup -Name ToyReusable -Location westus3

New-AzADServicePrincipal -AppId $applicationRegistration.AppId
New-AzRoleAssignment `
  -ApplicationId $applicationRegistration.AppId `
  -RoleDefinitionName Contributor `
  -Scope $resourceGroup.ResourceId

# Run the following code to show you the values you need to create as GitHub secrets

$azureContext = Get-AzContext
Write-Host "AZURE_CLIENT_ID: $($applicationRegistration.AppId)"
Write-Host "AZURE_TENANT_ID: $($azureContext.Tenant.Id)"
Write-Host "AZURE_SUBSCRIPTION_ID: $($azureContext.Subscription.Id)"
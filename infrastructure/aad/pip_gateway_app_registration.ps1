Param( [string]$tenantId = "" )
$displayNameApi = "pip-api-gateway-np"
$bodyApi = '{
    "signInAudience" : "AzureADandPersonalMicrosoftAccount", 
    "groupMembershipClaims": "None"
}' | ConvertTo-Json | ConvertFrom-Json
$userAccessScopeApi = '{
        "lang": null,
        "origin": "Application",        
        "adminConsentDescription": "Allow access to the PIP",
        "adminConsentDisplayName": "pip-api-gateway-access",
        "id": "--- replaced in scripts ---",
        "isEnabled": true,
        "type": "User",
        "userConsentDescription": "Allow access to PIP Gateway",
        "userConsentDisplayName": "Allow access to PIP Gateway",
        "value": "pip_api_write"
}' | ConvertTo-Json | ConvertFrom-Json
 
##################################
### testParams
##################################
 
function testParams {
 
    if (!$tenantId) 
    { 
        Write-Host "tenantId is null"
        exit 1
    }
}
 
testParams
 
Write-Host "Begin PIP Gateway Azure App Registration"
 
##################################
### Create Azure App Registration
##################################
 
$myApiAppRegistration = az ad app create `
    --display-name $displayNameApi `
    --available-to-other-tenants false `
    --oauth2-allow-implicit-flow  false
 
$myApiAppRegistrationResult = ($myApiAppRegistration | ConvertFrom-Json)
$myApiAppRegistrationResultAppId = $myApiAppRegistrationResult.appId

$identifierUrlApi = "api://" + $myApiAppRegistrationResultAppId
az ad app update --id $myApiAppRegistrationResultAppId --identifier-uris $identifierUrlApi
Write-Host " - Created API $displayNameApi with myApiAppRegistrationResultAppId: $myApiAppRegistrationResultAppId"

$keyVaultName = "pip-shared-kv-sbox"
az keyvault secret set --vault-name $keyVaultName --name "$displayNameApi-scope" --value $identifierUrlApi

##################################
### Add Roles to App Registration 
##################################

az ad app update --id $myApiAppRegistrationResultAppId --app-roles @pip-gateway-role.json
Write-Host " - Roles added to App Registration: $myApiAppRegistrationResultAppId"

##################################
###  Add scopes (oauth2Permissions)
##################################
 
# 1. read oauth2Permissions
$oauth2PermissionsApi = $myApiAppRegistrationResult.oauth2Permissions
# 2. set to enabled to false from the defualt scope, because we want to remove this
$oauth2PermissionsApi[0].isEnabled = 'false'
$oauth2PermissionsApi = ConvertTo-Json -InputObject @($oauth2PermissionsApi) 
Write-Host "$oauth2PermissionsApi"

# disable oauth2Permission in Azure App Registration
$oauth2PermissionsApi | Out-File -FilePath .\oauth2Permissionsold.json
az ad app update --id $myApiAppRegistrationResultAppId --set oauth2Permissions=`@oauth2Permissionsold.json
 
# 3. delete the default oauth2Permission
az ad app update --id $myApiAppRegistrationResultAppId --set oauth2Permissions='[]'

# 4. add the new scope required add the new oauth2Permissions values
$newIdentifier = New-Guid
Write-Host "New permission id: $newIdentifier"
$oauth2PermissionsApiNew = $userAccessScopeApi | ConvertFrom-Json
$oauth2PermissionsApiNew[0].id = $newIdentifier
$oauth2PermissionsApiNew = ConvertTo-Json -InputObject @($oauth2PermissionsApiNew) 
$oauth2PermissionsApiNew | Out-File -FilePath .\oauth2Permissionsnew.json
az ad app update --id $myApiAppRegistrationResultAppId --set oauth2Permissions=@oauth2Permissionsnew.json
Write-Host " - Updated scopes (oauth2Permissions) for App Registration: $app$myApiAppRegistrationResultAppId"`

##################################
###  Create a ServicePrincipal for the API App Registration
##################################
 
az ad sp create --id $myApiAppRegistrationResultAppId | Out-String | ConvertFrom-Json
Write-Host " - Created Service Principal for API App registration"
 
return $myApiAppRegistrationResultAppId
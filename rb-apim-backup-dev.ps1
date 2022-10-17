<#
    .SYNOPSIS
    Azure automation PS script to backup Azure API Management configuration
      
    .PREREQUISITES
    IAM/RBAC Configuration 
      umiAppId -> API Management Service Operator Role on APIM ressource
      umiAppId -> Managed Identity Operator on apimIdName
      apimIdName -> Storage Blob Data Contributor on Storage Account container

    .PARAMETER <Object Principal ID - optional>
    User Managed id for script context with role allowing APIM backup and reading User Managed ID associated with APIM
    
    .EXAMPLE 
    Bicep:
        ..Microsoft.Automation/automationAccounts/runbook@..
        properties: {
        ..
        runbookType: 'PowerShell'
        publishContentLink:  
          { uri: 'https://raw.githubusercontent.com/<repos>/main/rb-apim-backup-dev.ps1' }
        }
    
    .LINK
    Reference : https://docs.microsoft.com/en-us/azure/api-management/api-management-howto-disaster-recovery-backup-restore
    Backup-AzApiManagement : https://docs.microsoft.com/en-us/powershell/module/az.apimanagement/backup-azapimanagement
#>

# User Managed id for script context (Object Principal id)
# RBAC
# umiAppId -> API Management Service Operator Role on APIM ressource
# umiAppId -> Managed Identity Operator on apimIdName
# apimIdName -> Storage Blob Data Contributor on Storage Account container

Param
(
    [Parameter (Mandatory= $false)]
    [string]$umiAppId='2864b0f8-fd9b-4056-b045-542d9c2dbf2d'
)


# Ensures AzContext is not inherited.
Disable-AzContextAutosave -Scope Process

# Get UMI App ID - Does not work without context
# (Get-AzADServicePrincipal -DisplayName uamiautacc1).AppId

# Connect to Azure with user-assigned managed identity
$AzureContext = (Connect-AzAccount -Identity -AccountId $umiAppId).context

# set and store context
$AzureContext = Set-AzContext -SubscriptionName $AzureContext.Subscription -DefaultProfile $AzureContext

(Get-AzContext).Subscription.id
(Get-AzContext).Account.id

### Backup APIM using UMI with Storage acc permission

$apiManagementName="bmgapimtest1";
$apiManagementResourceGroup="DemoRG001";
$storageAccountName="audevinautbackup";
$storageResourceGroup="AU-Common-Backup-Resources";
$containerName="forbackup01";
$blobName="apimbackup_" + (Get-Date).tostring("dd-MM-yyyy-hh-mm-ss") 

$apimIdName = "audev-integration-apimgr-mi";
$identityResourceGroup = "DemoRG001";

$identityId = (Get-AzUserAssignedIdentity -Name $apimIdName -ResourceGroupName $identityResourceGroup).ClientId
Write-Output $identityId

$storageContext = New-AzStorageContext -StorageAccountName $storageAccountName

$StartTime = get-date 

Write-Output "Starting backup of $apiManagementName" 

Backup-AzApiManagement -ResourceGroupName $apiManagementResourceGroup -Name $apiManagementName `
    -StorageContext $storageContext -TargetContainerName $containerName `
    -TargetBlobName $blobName -AccessType "UserAssignedManagedIdentity" ` -identityClientId $identityid
$exitCode=$LASTEXITCODE

if ($exitCode -ne 0) {
 Write-Error "Backup of $apiManagementName failed with exit code $exitCode"
} else {
  $RunTime = New-TimeSpan -Start $StartTime -End (get-date) 
  Write-Output "End Backup, elapsed: $RunTime"
}

exit $exitCode

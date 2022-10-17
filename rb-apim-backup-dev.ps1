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

$identityName = "audev-integration-apimgr-mi";
$identityResourceGroup = "DemoRG001";

$identityId = (Get-AzUserAssignedIdentity -Name $identityName -ResourceGroupName $identityResourceGroup).ClientId
Write-Output $identityId

$storageContext = New-AzStorageContext -StorageAccountName $storageAccountName

$StartTime = get-date 

Write-Output "Starting backup of $apiManagementName" 

Backup-AzApiManagement -ResourceGroupName $apiManagementResourceGroup -Name $apiManagementName `
    -StorageContext $storageContext -TargetContainerName $containerName `
    -TargetBlobName $blobName -AccessType "UserAssignedManagedIdentity" ` -identityClientId $identityid

#Start-Sleep -s 5

$RunTime = New-TimeSpan -Start $StartTime -End (get-date) 

Write-Output "End Backup, elapsed: $RunTime"

exit $LASTEXITCODE

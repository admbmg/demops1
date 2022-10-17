Param
(
    [Parameter (Mandatory= $false)]
    [string]$umiAppId='2c1101c6-a761-4483-bb60-de1564739c54'
)


# Ensures you do not inherit an AzContext in your runbook
Disable-AzContextAutosave -Scope Process

# Get UMI App ID - Does not work without context
# (Get-AzADServicePrincipal -DisplayName uamiautacc1).AppId

# Connect to Azure with user-assigned managed identity
$AzureContext = (Connect-AzAccount -Identity -AccountId 2c1101c6-a761-4483-bb60-de1564739c54).context

# set and store context
$AzureContext = Set-AzContext -SubscriptionName $AzureContext.Subscription -DefaultProfile $AzureContext

(Get-AzContext).Subscription.id
(Get-AzContext).Account.id

### Backup APIM using UMI with Storage acc permission

$apiManagementName="bmgapimtest1";
$apiManagementResourceGroup="DemoRG001";
$storageAccountName="demoback2";
$storageResourceGroup="DemoRG001";
$containerName="backup1";
$blobName="apimbackup_" + (Get-Date).tostring("dd-MM-yyyy-hh-mm-ss") 

$identityName = "uamitest";
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

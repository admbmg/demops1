$apiManagementName="bmgapimtest1";
$apiManagementResourceGroup="DemoRG001";
$storageAccountName="demoback2";
$storageResourceGroup="DemoRG001";
$containerName="backup1";
$blobName="apimbackup"

$identityName = "uamitest";
$identityResourceGroup = "DemoRG001";

$identityId = (Get-AzUserAssignedIdentity -Name $identityName -ResourceGroupName $identityResourceGroup).ClientId

$storageContext = New-AzStorageContext -StorageAccountName $storageAccountName

Backup-AzApiManagement -ResourceGroupName $apiManagementResourceGroup -Name $apiManagementName `
    -StorageContext $storageContext -TargetContainerName $containerName `
    -TargetBlobName $blobName -AccessType "UserAssignedManagedIdentity" ` -identityClientId $identityid
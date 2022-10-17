$apiManagementName="bmgapimtest1";
$apiManagementResourceGroup="DemoRG001";
$storageAccountName="audevinautbackup";
$storageResourceGroup="AU-Common-Backup-Resources";
$containerName="forbackup01";
$blobName="apimbackup_" + (Get-Date).tostring("dd-MM-yyyy-hh-mm-ss") 

$identityName = "audev-integration-apimgr-mi";
$identityResourceGroup = "DemoRG001";

$identityId = (Get-AzUserAssignedIdentity -Name $identityName -ResourceGroupName $identityResourceGroup).ClientId

$storageContext = New-AzStorageContext -StorageAccountName $storageAccountName

Backup-AzApiManagement -ResourceGroupName $apiManagementResourceGroup -Name $apiManagementName `
    -StorageContext $storageContext -TargetContainerName $containerName `
    -TargetBlobName $blobName -AccessType "UserAssignedManagedIdentity" ` -identityClientId $identityid
exit $LASTEXITCODE

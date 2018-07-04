$homeDriveRoot = "\\hs-data\staff$\"
$leaversRoot = "\\hs-data\leftstaff$\"

$folders = Get-ChildItem $homeDriveRoot | Select -ExpandProperty Name
$activeUsers =  Get-ADUser -Filter {Enabled -eq $true} | Select -ExpandProperty SamAccountName
$differences = Compare-Object -ReferenceObject $activeUsers -DifferenceObject $folders | ? {$_.SideIndicator -eq "=>"} | Select -ExpandProperty InputObject
$differences | ForEach-Object {Move-Item -Path "$homeDriveRoot$_" -Destination "$leaversRoot$_" -Force}
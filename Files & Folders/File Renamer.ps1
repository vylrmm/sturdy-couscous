$rootPath = "C:\Test"
#Test
$folderChild = $rootPath | Get-ChildItem
foreach ($folder in $folderChild){
    $folder | Get-ChildItem | Rename-Item -NewName "TestName.csv"
}
#CSV
$support = "C:\User Scripts\Scripts\Outlook Reg File\CSVs\Support Staff.csv"
$admin = "C:\User Scripts\Scripts\Outlook Reg File\CSVs\Admin Staff.csv"
$teaching = "C:\User Scripts\Scripts\Outlook Reg File\CSVs\Teaching Staff.csv"
#Imports
$importedFile = Get-Content -Path $support | Select -skip 1 | ConvertFrom-Csv -Header SamAccountName, mailNickName -Delimiter ","
#Loops
foreach($user in $importedFile){
    $sigPath = "\\exch\d$\Outlook\EmailSignature"
    $regPath = "\\exch\d$\Outlook"
    $regExt = ".reg"
    $samName = $user.SamAccountName
    $nickName = $user.mailNickName
    Write-Host $samName
    Write-Host $nickName
    if(Test-Path $sigPath\$samName){
        Rename-Item -Path $sigPath\$samName -NewName $sigPath\$nickName
    }
    if(Test-Path $regPath\$samName$regExt){
        Rename-Item -Path $regPath\$samName$regExt -NewName $regPath\$nickName$regExt         
    }
}

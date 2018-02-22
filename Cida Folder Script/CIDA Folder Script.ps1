$csvFile = "C:\Scripts\Exam Accounts.csv"
$cidaPath = "C:\Scripts\Cida Accounts"
$dstFolder = "C:\Scripts\Cida Accounts\Cida"
$assets = "C:\Scripts\Assets\"

Import-Csv $csvFile | ForEach-Object{
    $foldername = $_.CentNum + "_" +  $_.CandNum + "_" +  $_.Lname + "_" + $_.Fname
    $examID = $_.ExamID
    $pathEnd = "Documents\desktop"
    New-Item -Path $cidaPath\$examID\$pathEnd -Name $foldername -ItemType "Directory" 
}
$folderAmount = (Get-ChildItem 'C:\Scripts\Cida Accounts' | Measure-Object | Select-Object Count).count
for($i = 1; $i -le $folderAmount; $i++){
    $newI = "{0:D2}" -f $i
    Copy-Item -Path $assets -Recurse -Destination $dstFolder$newI\$pathEnd
}   
#Created by DJW & RMM the Vital Scripting Team.

$pstFiles = "C:\Scripts\PST Files"
$dstPath = "C:\Scripts\New Location"
$outputName = "CYC Mailbox.pst"

$pstlog = "C:\Scripts\PSTLog.txt"

$csvFile = "C:\Scripts\test.csv"

Import-Csv $csvFile | ForEach-Object{
    $foldername = $_.Name
    $pstName = $foldername + ".pst"
    $sourcepst = "$pstFiles"
    $newdst = "$dstpath\$foldername"
    robocopy $sourcepst $newdst $pstName /log+:$pstlog
    Rename-Item -Path $newdst\$pstname -NewName $outputName
}

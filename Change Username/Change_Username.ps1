#Changes the username based on the mail account nickname.
Import-Module ActiveDirectory
#Paths
$ou = "OU=TestOU,OU=Staff,OU=Users,OU=Huntington School,DC=huntington-ed,DC=org ,DC=uk"
#Log Files
$breakLine = "************************************************************************************"
$changeFile = "C:\User Scripts\Scripts\Change Username\changeFile.txt"
$notrestoreFile = "C:\User Scripts\Scripts\Change Username\none_restored_users.txt"
$restoreFile = "C:\User Scripts\Scripts\Change Username\restored_users.txt"
$errorLog = "C:\User Scripts\Scripts\Change Username\errors.txt"
#Exported Files
$exportedFile = "C:\User Scripts\Scripts\Change Username\Backup of Users.csv"
$newUsers = "C:\User Scripts\Scripts\Change Username\New Users Exported.csv"

#Get users from AD
$users = Get-ADUser -SearchBase $ou -Filter * -Properties * -ResultSetSize 1000  | Select-Object GivenName, Surname, Mail, mailNickName, homeDirectory, profilePath, SamAccountName

#Restores users from exported backup file
Function restoreUsernames(){
    $importedFile = Get-Content -Path "C:\User Scripts\Scripts\Change Username\Backup of Users.csv" | Select -Skip 2 | ConvertFrom-Csv -Header GivenName, Surname, Mail, mailNickName, homeDirectory, profilePath, SamAccountName -Delimiter ","
    foreach ($user in $importedFile){
        $oldMail = $user.Mail
        #If not Mail account then don't change anything, as nothing was changed prior to this.
        if($oldMail -ne ""){
            $oldGivenname = $user.GivenName
            $oldSurname = $user.Surname
            $oldHomeFolder = $user.homeDirectory
            $oldMailNick = $user.mailNickName
            $oldProfile = $user.profilePath
            $oldSamName = $user.SamAccountName
            $huntingtonDomain = "@huntington-ed.org.uk"
            Set-ADUser -Identity $oldMailNick -Replace @{homeDirectory=$oldHomeFolder;mailNickName=$oldMailNick;GivenName=$oldGivenname;sn=$oldSurname}
            Set-ADUser -Identity $oldMailNick -SamAccountName $oldSamName -UserPrincipalName $oldSamname$huntingtonDomain -PassThru | Rename-ADObject -NewName $oldMailNick
            $homefolderPath = "\\HS-DATA\Staff$"
            Rename-Item -Path $homefolderPath\$oldMailNick -NewName $homefolderPath\$oldSamName
            $restored = "User: " + $user.SamAccountName + " has been restored."
            $restoredFName = "First Name: " + $user.GivenName
            $restoredLName = "Last Name: " + $user.Surname
            $restoredHome = "Home Folder (Directory): " + $user.homeDirectory
            Add-Content $restoreFile $breakLine
            Add-Content $restoreFile $restored, $restoredFName, $restoredLName, $restoredHome

            $sigPath = "\\exch\d$\Outlook\EmailSignature"
            $regPath = "\\exch\d$\Outlook"
            $regExt = ".reg"
            if(Test-Path $regPath\$oldSamName$regExt){
            Rename-Item -Path $regPath\$oldMailNick$regExt -NewName $regPath\$oldSamName$regExt
            }
            if(Test-Path $sigPath\$oldSamName){
                Rename-Item -Path $sigPath\$oldMailNick -NewName $sigPath\$oldSamName
            }
            #Replaces Profile is Exists
            if($oldProfile -ne ""){
                $currentProfile = "\\HS-DATA\Profiles$\Staff"
                $profileEnd = ".V6"
                if(Test-Path $currentProfile\$oldSamName$profileEnd){
                    Rename-Item -Path $currentProfile\$oldMailNick$profileEnd -NewName $currentProfile\$oldSamName$profileEnd
                    set-ADUser -Identity $oldMailNick -ProfilePath $currentProfile\$oldSamName
                    $profileRestored = "Profile Path (Directory): " + $user.profilePath
                    Add-Content $restoreFile $profileRestored
                }
            }
        } else {
            $noRestore = "User: " + $user.SamAccountName + "User not restored due to no mailbox existing for user."
            Add-Content $notrestoreFile $breakLine
            Add-Content $notrestoreFile $noRestore        
        }
    } 
}
#Changes the Usernames.
Function changeUsername(){
    Foreach($user in $users){
        $mailName = $user.Mail
        if($mailName -ne $null){
            $samName = $user.SamAccountName
            $nickName = $user.mailNickName
            $profileName = $user.profilePath
            $homeName = $user.homeDirectory
            Add-Content $changeFile $breakLine
            $logHeader = "Changes to the user: " + $samName
            Add-Content $changeFile $logHeader
            #Changes Profile Path and Folder Name
            if($profileName -ne $null){
                $currentProfile = "\\HS-DATA\Profiles$\Staff"
                $profileEnd = ".V6"
                if(Test-Path $currentProfile\$samName$profileEnd){
                    Rename-Item -Path $currentProfile\$samName$profileEnd -NewName $currentProfile\$nickName$profileEnd
                    Set-ADUser -Identity $samName -ProfilePath $currentProfile\$nickName
                    $renamedProfile = "New Profile Path: "+ $currentProfile + "\" + $nickName
                    Add-Content $changeFile $renamedProfile
                }
            }
            #Changes Home Directory and Folder Name
            if($homeName -ne $null){
                $homefolderPath = "\\HS-DATA\Staff$"
                $thewordDocuments = "documents"
                $huntingtonDomain = "@huntington-ed.org.uk"
                Rename-Item -Path $homefolderPath\$samName -NewName $homefolderPath\$nickName
                Set-ADUser -Identity $samName -HomeDirectory $homefolderPath\$nickName\$thewordDocuments
                $renamedHome = "New Home Directory: "+ $homefolderPath + "\" + $nickName + "\" + $thewordDocuments
                Add-Content $changeFile $renamedHome
            }
            #Changes Exch reg folder
            $sigPath = "\\exch\d$\Outlook\EmailSignature"
            $regPath = "\\exch\d$\Outlook"
            $regExt = ".reg"
            if(Test-Path $sigPath\$samName){
                Rename-Item -Path $sigPath\$samName -NewName $sigPath\$nickName
            }
            if(Test-Path $regPath\$samName$regExt){
                Rename-Item -Path $regPath\$samName$regExt -NewName $regPath\$nickName$regExt         
            }
            if($nickName -ne $samName){
                Set-ADUser -Identity $samName -SamAccountName $nickName -UserPrincipalName $nickName$huntingtonDomain -PassThru | Rename-ADObject -NewName $nickName
                Get-ADUser -SearchBase $ou -Filter * -Properties * | Select-Object GivenName, Surname, Mail, mailNickName, homeDirectory, profilePath, SamAccountName | Export-CSV $newUsers
                $userChanges = "New Username: " + $nickName
                Add-Content $changeFile $userChanges
            } else {
                $userExists = $user.SamAccountName + " already exists in Active Directory."
                Add-Content $errorLog $userExists
                }
        } else {
            $errorMessage = $user.SamAccountName + "does not have a mailbox so no changes were made."
            Add-Content $errorlog $breakLine
            Add-Content $errorLog $errorMessage
        }
    }
}
#Backup the current users.
$backupPrompt = Read-Host -Prompt "Do you want to backup the current users from AD?"
if($backupPrompt -eq "y"){
    Get-ADUser -SearchBase $ou -Filter * -Properties * | Select-Object GivenName, Surname, Mail, mailNickName, homeDirectory, profilePath, SamAccountName, cn | Export-CSV $exportedFile
    Write-Host "Users have been backed up."
    Start-Sleep -s 3
    $changePrompt = Read-Host -Prompt "Do you want to change the usernames?"
    if($changePrompt -eq "y"){
        Write-Host "Changing Usernames...."
        changeUsername
        Write-Host "Exported new usernames to Spreadsheet..."
    } else {
        continue
    }
} elseif($backupPrompt -eq "n"){
    Write-Host "Users not backed up..."
    $restorePrompt = Read-Host -Prompt "Do you you want to restore the users from the backup?"
    if($restorePrompt -eq "y"){
        restoreUsernames
        Write-Host "Restoring users....."
    } else{
        continue
    }
}

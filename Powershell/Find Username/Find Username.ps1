Import-Module ActiveDirectory

#Global Variables
$users = Get-Content "C:\User Scripts\Scripts\Find Username Script\Output\import.csv"
$exportpath = "C:\User Scripts\Scripts\Find Username Script\Output\exported.csv"
#Can you repeat the question
$yes,$no,$y,$n = "yes","no,","y","n"

#Checks if user wants to append to current file or start a new file
if(Test-Path $exportpath){
    $usercheck = $True
    while($usercheck){
        $queryremoval = Read-Host -Prompt "Would you like to remove the old exported file first? Y/N"
        if($queryremoval -eq $yes -or $queryremoval -eq $y){
            Remove-Item "C:\User Scripts\Scripts\Find Username Script\Output\exported.csv"
            "The file has been wiped."
            $usercheck = $False
            } elseif($queryremoval -eq $no -or $queryremoval -eq $n){
                "New created users will append onto the current list."
                $usercheck = $False               
                } else{
                "Please enter Y/N"
                $usercheck = $True
                }
    }
}
#Gets name from First name and Last name imported from $users
foreach ($user in $users){
    $SplitName = -split $user
    $Fname=$SplitName[0]
    $Lname=$splitName[1]
    Get-ADUser -Filter {(GivenName -eq $Fname) -and (Surname -eq $Lname)} | Select-Object GivenName, Surname, name | Export-Csv -Append -Path "C:\User Scripts\Scripts\Find Username Script\Output\exported.csv"
    }

#Adds member to a group if "Y"
$groupcheck = $True
while($groupcheck){
    $addtogroup = Read-Host -Prompt "Do you want to add the users to a group?"
    if($addtogroup -eq "yes" -or $addtogroup -eq "y"){
        $grouptest = $true
        while($grouptest){
            $group = Read-Host -Prompt "What is the name of the group?"
            $existcheck = Get-ADGroup -LDAPFilter "(SAMAccountName=$group)"
            if($existcheck){
                Import-Csv "C:\User Scripts\Scripts\Find Username Script\Output\exported.csv" | %{ add-adgroupmember $group -member $_.name}
                "The users have been added to $group"
                $groupcheck = $False
                $grouptest = $False
                } else {
                    "The group doesn't exist or was spelt incorrectly."
                    $groupcheck = $true
                    $grouptest = $true   
                } 
            }
        }          
    elseif($addtogroup -eq "no" -or $addtogroup -eq "n"){
            $groupcheck = $False
            "No users were added to a group"
        } else {
        "Please enter Y/N"
        $groupcheck = $True
        }
    
}





 
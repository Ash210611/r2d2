Import-Module C:\TimeZone\UserRights.psm1

$timeInSeconds = 60
$LogLocation = "C:\TimeZone\Log.txt"


"Validating User has Right for $timeInSeconds seconds" >> $LogLocation
for( $i = 0; $i -lt $timeInSeconds; $i++){
    $logString = ""
    $logString += (Get-Date -Format G)
    $DoesUsersHaveRight = (Get-AccountsWithUserRight -Right SeTimeZonePrivilege).Account -contains "BUILTIN\Users"
    if ($DoesUsersHaveRight -eq $true){
       $logString+= " UserHasRight"
    }else {
        $logString+= " UserDoesntHaveRight"
        $logString >> $LogLocation

        "Granting User Right" >> $LogLocation
        Grant-UserRight -Account "Users" -Right SeTimeZonePrivilege
        "Leaving Program" >> $LogLocation
        break
    }
    $logString >> $LogLocation
    Sleep -Seconds 1
}
"Time Is Up" >> C:\TimeZone\Log.txt
$DoesUsersHaveRight = (Get-AccountsWithUserRight -Right SeTimeZonePrivilege).Account -contains "BUILTIN\Users"
"User Has Right: $DoesUsersHaveRight"
# Import the Library to do Region/Profile Switching
. C:\AutoConfig\RegionSwitcherLibrary.ps1

[string]$Script:LastRegionFile = "C:\Users\Public\history.txt"

# What we will set the machine to when a member of
# the fleet is logged in to
$proxy = 'None'
$language = 'None'
$timezone = 'Coordinated Universal Time'

function Clear-RegionHistory(){
    Write-Host "Updating Files"
    Remove-Item $Script:LastRegionFile
}

# Deletes all local Splunk Logs
function Clear-SplunkLogs(){
  cd "C:/Program Files/SplunkUniversalForwarder/var/log/splunk"
  Get-ChildItem | Remove-Item
}

# Sets the proxy to the settings above, typically clearing it
function Clear-Proxy(){
  "-1" > "C:\Users\Public\history.txt"
  ChangeRegion  -proxyConnectionString $proxy -language $language -timezone $timezone -proxy $proxy
}

$d = date 
echo $d >> "C:\AutoConfig\CookieGuard.log"
Clear-Proxy
echo "Proxy Cleared" >> "C:\AutoConfig\CookieGuard.log"
Clear-RegionHistory
echo "Region History Cleared" >> "C:\AutoConfig\CookieGuard.log"
Clear-SplunkLogs
echo "Splunk Logs Cleared" >> "C:\AutoConfig\CookieGuard.log"

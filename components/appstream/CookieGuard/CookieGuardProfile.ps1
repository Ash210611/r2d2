# Import the Library to do Region/Profile Switching
. C:\AutoConfig\RegionSwitcherLibrary.ps1

[string]$Script:LastRegionFile = "C:\Users\Public\history.txt"
[string]$Script:HomepageSiteHistory = "C:\inetpub\wwwroot\history.txt"

# What we will set the machine to when a member of
# the fleet is logged in to
$proxy = 'None'
$language = 'None'
$timezone = 'Coordinated Universal Time'
$lastProfile = Get-Content "C:\Profiles\LastProfile.txt"

function Clear-RegionHistory(){
    Write-Host "Updating Files"
    Remove-Item $Script:LastRegionFile
    Remove-Item $Script:HomepageSiteHistory
}





# Deletes all local Splunk Logs
function Clear-SplunkLogs(){
  cd "C:/Program Files/SplunkUniversalForwarder/var/log/splunk"
  Get-ChildItem | Remove-Item
}

# Sets the proxy to the settings above, typically clearing it
function Clear-Proxy(){
  "-1" > "C:\Users\Public\history.txt"
  ChangeRegionAndProfile  -proxyConnectionString $proxy -language $language -timezone $timezone -oldProfile $lastProfile -newProfile ''
}


$d = date 
echo $d >> "C:\AutoConfig\CookieGuard.log"
Clear-Proxy
echo "Proxy Cleared" >> "C:\AutoConfig\CookieGuard.log"
Clear-RegionHistory
echo "Region History Cleared" >> "C:\AutoConfig\CookieGuard.log"
Clear-SplunkLogs
echo "Splunk Logs Cleared" >> "C:\AutoConfig\CookieGuard.log"

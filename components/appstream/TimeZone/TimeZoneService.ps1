$timezoneupdatefile = "C:\AutoConfig\TimeZoneUpdate.txt"
$timezonelogfile = "C:\AutoConfig\TimeZoneLog.txt"

for($i = 0; $i -lt 60; $i++){
    if (Test-Path $timezoneupdatefile){
        $timezone = Get-Content -Path $timezoneupdatefile
        $date = (Get-Date -Format G)
        "$date  Changing Time Zone to $timezone" >> $timezonelogfile
        Set-TimeZone $timezone
        rm $timezoneupdatefile
    }
    Sleep 1
}
#Path variables
$r2d2path = "C:\Deployment\r2d2\components\appstream"

#Set variables for requested zone 
$r2d2launchervalue = "r2d2-launcher-prod"

#udate chrome settings 
Set-ItemProperty -Path "HKLM:\Software\Policies\Google\Chrome\" -Name ManagedBookmarks -Type String -Value "[{""toplevel_name"": ""Bookmarks""},{""name"": ""Homepage"", ""url"": ""https://$r2d2launchervalue.s3.amazonaws.com/homepage.html""},{""name"": ""Facebook"", ""url"": ""https://facebook.com/public/Search""},{""name"": ""Find my Facebook ID"", ""url"": ""https://lookup-id.com/""},{""name"": ""Twitter"", ""url"": ""https://twitter.com/search""},{""name"": ""Find my Twitter ID"", ""url"": ""http://gettwitterid.com/"" }, { ""name"": ""Instagram"",""url"": ""https://www.instagram.com/instagram""}, {""name"": ""Google"", ""url"": ""https://www.google.com""},{""name"": ""Google Translate"", ""url"": ""https://translate.google.com/""}]"
Set-ItemProperty -Path "HKLM:\Software\Policies\Google\Chrome\PopupsAllowedForUrls" -Name 1 -Type String -Value "$r2d2launchervalue.s3.amazonaws.com"


#update firefox settings (mozilla.cfg)
$FFcfg = Get-Content -Path 'C:\AutoConfig\mozilla.cfg' -Raw
$modFFcfg = $FFcfg | % {
        $modVal = $_
        $modVal = $modVal -replace 'r2d2-launcher-nonprod', $r2d2launchervalue
        $modVal
}
Set-Content -Path 'C:\AutoConfig\mozilla.cfg' -Value $modFFcfg -Force
Set-Content -Path 'C:\Program Files\Mozilla Firefox\mozilla.cfg' -Value $modConfig -Force


#update Region Switcher
$RScfg = Get-Content -Path 'C:\AutoConfig\RegionSwitcherLibrary.ps1' -Raw
$modRScfg = $RScfg | % {
        $modVal = $_
        $modVal = $modVal -replace 'r2d2-launcher-nonprod', $r2d2launchervalue
        $modVal
}
Set-Content -Path 'C:\AutoConfig\RegionSwitcherLibrary.ps1' -Value $modRScfg -Force

#update Splunkforwarder output IP address
$SFcfg = Get-Content -Path 'C:\Program Files\SplunkUniversalForwarder\etc\system\local\outputs.conf' -Raw
$modSFcfg = $SFcfg | % {
        $modVal = $_
        $modVal = $modVal -replace '10.60.2.75', '10.70.2.77'
        $modVal
}
Set-Content -Path 'C:\Program Files\SplunkUniversalForwarder\etc\system\local\outputs.conf' -Value $modSFcfg -Force

#update Proxy Config
$PCcfg = Get-Content -Path 'C:\AutoConfig\ProxyConfig.csv' -Raw
$modPCcfg = $PCcfg | % {
        $modVal = $_
        $modVal = $modVal -replace 'r2d2hostedzone', 'r2d2hostedzon-fic'
        $modVal
}
Set-Content -Path 'C:\AutoConfig\ProxyConfig.csv' -Value $modPCcfg -Force


#Update Chrome
$proxy = "us-east-1.r2d2hostedzone:3128"
$regKey="HKCU:\Software\Microsoft\Windows\CurrentVersion\Internet Settings"
Set-ItemProperty -path $regKey ProxyEnable -value 1
Set-ItemProperty -path $regKey ProxyServer -value $proxy


$chromeText = "start `"Chrome`" `"C:\Program Files\Google\Chrome\Application\chrome.exe`" --new-window --disable-signin-promo --no-first-run --disable-sync --start-maximized `"chrome://settings/help`""
Set-Content "C:\Shortcuts\chrome.bat" "${chromeText}" -Encoding ASCII
Start "C:\Shortcuts\chrome.bat"

Sleep 2
$wshell = New-Object -ComObject wscript.shell
$wshell.AppActivate('Chrome')
Sleep 1
$wshell.SendKeys('chrome://settings/help')
Sleep 0.5
$wshell.SendKeys("{ENTER}")
Sleep 200
$wshell.AppActivate('Chrome')
Sleep 1
$wshell.SendKeys("%{F4}")


#Update Firefox
$firefoxText = "start `"Firefox`" `"C:\Program Files\Mozilla Firefox\firefox.exe`"  -profile `"C:\BrowserData\Firefox`" about:preferences#general"
Set-Content "C:\Shortcuts\firefox.bat" "${firefoxText}" -Encoding ASCII
Start "C:\Shortcuts\firefox.bat"
Sleep 200
$wshell = New-Object -ComObject wscript.shell
$wshell.SendKeys("%{F4}")
Start "C:\Shortcuts\firefox.bat"

#Turn off System Proxy
Set-ItemProperty -path $regKey ProxyEnable -value 0
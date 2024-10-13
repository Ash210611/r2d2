#Path variables
$r2d2path = "C:\Deployment\appstream"

#make directories
mkdir "C:\deployment"
mkdir "C:\AutoConfig"
mkdir "C:\BrowserData"
mkdir "C:\Shortcuts"
mkdir "C:\Profiles"

#Download the package
$env:AWS_PROFILE='appstream_machine_role'
aws s3 cp "s3://r2d2-binaries/GoogleChromeEnterpriseBundle64.zip" "C:\deployment\"
aws s3 cp "s3://r2d2-binaries/Firefox Setup 119.0 64-bit.msi" "C:\deployment\Firefox.msi"
aws s3 cp "s3://r2d2-binaries/splunkforwarder-9.1.1-64e843ea36b1-x64-release.msi" "C:\deployment\splunkforwarder.msi"
aws s3 cp "s3://r2d2-binaries/appstream.zip" "C:\deployment\"

#Unzip package
Expand-Archive -Path "C:\deployment\appstream.zip" -DestinationPath "C:\deployment"



#Install Google Chrome
Expand-Archive -Path "C:\deployment\GoogleChromeEnterpriseBundle64.zip" -DestinationPath "C:\deployment" -Force
Start-Process msiexec.exe -Wait -ArgumentList '/I C:\deployment\Installers\GoogleChromeStandaloneEnterprise64.msi /quiet'
Write-Host "installed google chrome"

#uninstall Firefox 
&"${r2d2path}\UninstallFirefox.ps1"


#now install firefox 64
Start-Process msiexec.exe -Wait -ArgumentList '/I C:\deployment\Firefox.msi /quiet'
Write-Host "installed Firefox 64"


#Set the Chrome GPO the way we want
#Chrome Extensions
New-Item -Path "HKLM:\Software\Policies\Google\Chrome\" -Force
New-Item -Path "HKLM:\Software\Policies\Google\Update\" -Force
New-Item -Path "HKLM:\Software\Policies\Google\Chrome\ExtensionInstallForcelist" -Force
New-Item -Path "HKLM:\Software\Policies\Google\Chrome\PopupsAllowedForUrls" -Force
New-Item -Path "HKLM:\Software\Policies\Google\Chrome\JavaScriptBlockedForUrls" -Force
New-Item -Path "HKLM:\Software\Policies\Google\Chrome\InsecureContentAllowedForUrls" -Force
Set-ItemProperty -Path "HKLM:\Software\Policies\Google\Chrome\ExtensionInstallForcelist" -Name 1 -Value "haebnnbpedcbhciplfhjjkbafijpncjl;https://clients2.google.com/service/update2/crx" -Type String
Set-ItemProperty -Path "HKLM:\Software\Policies\Google\Chrome\ExtensionInstallForcelist" -Name 2 -Value "immpkjjlgappgfkkfieppnmlhakdmaab;https://clients2.google.com/service/update2/crx" -Type String
Set-ItemProperty -Path "HKLM:\Software\Policies\Google\Chrome\ExtensionInstallForcelist" -Name 3 -Value "fkjbliednplpohojfpgnbpcppgdnhklb;https://clients2.google.com/service/update2/crx" -Type String
Set-ItemProperty -Path "HKLM:\Software\Policies\Google\Chrome\ExtensionInstallForcelist" -Name 4 -Value "djflhoibgkdhkhhcedjiklpkjnoahfmg;https://clients2.google.com/service/update2/crx" -Type String
Set-ItemProperty -Path "HKLM:\Software\Policies\Google\Chrome\ExtensionInstallForcelist" -Name 5 -Value "ihmmlfacoffajllfpdfkdikgmoogbnph;https://clients2.google.com/service/update2/crx" -Type String
Set-ItemProperty -Path "HKLM:\Software\Policies\Google\Chrome\" -Name ManagedBookmarks -Type String -Value '[{"toplevel_name": "Confirmed Account Tools"}, { "name": "Homepage","url": "https://r2d2-launcher-nonprod.s3.amazonaws.com/homepage.html" }, { "name": "Facebook Lookup-ID","url": "https://lookup-id.com" }, { "name": "Facebook CommentPicker","url": "https://commentpicker.com/find-facebook-id.php" }, { "name": "Twitter CodeNinja","url": "https://codeofaninja.com/tools/find-twitter-id" }, { "name": "Instagram InstaFollowers","url": "http://www.instafollowers.co/find-instagram-user-id" }, { "name": "YouTube CommentPicker","url": "https://commentpicker.com/youtube-channel-id.php" }, { "name": "TikTok InstaFollowers","url": "https://www.instafollowers.co/find-tiktok-user-id" }, { "name": "Google Search","url": "https://www.google.com" }, { "name": "Google Translate","url": "https://translate.google.com" }]'
Set-ItemProperty -Path "HKLM:\Software\Policies\Google\Chrome\" -Name BookmarkBarEnabled -Type DWord -Value 1
Set-ItemProperty -Path "HKLM:\Software\Policies\Google\Chrome\" -Name ShowAppsShortcutInBookmarkBar -Type DWord -Value 0
Set-ItemProperty -Path "HKLM:\Software\Policies\Google\Chrome\" -Name UserDataDir -Type String -Value "C:\BrowserData\Chrome\"
Set-ItemProperty -Path "HKLM:\Software\Policies\Google\Chrome\" -Name DefaultBrowserSettingEnabled -Type DWord -Value 0
Set-ItemProperty -Path "HKLM:\Software\Policies\Google\Chrome\" -Name ProxySettings -Type String -Value '{"ProxyMode":"fixed_servers","ProxyServer":"none"}'
Set-ItemProperty -Path "HKLM:\Software\Policies\Google\Chrome\PopupsAllowedForUrls" -Name 1 -Type String -Value 'r2d2-launcher-nonprod.s3.amazonaws.com'
Set-ItemProperty -Path "HKLM:\Software\Policies\Google\Chrome\JavaScriptBlockedForUrls" -Name 1 -Type String -Value 'mobile.twitter.com'
Set-ItemProperty -Path "HKLM:\Software\Policies\Google\Chrome\InsecureContentAllowedForUrls" -Name 1 -Value "[*.]picuki.com" -Type String
Set-ItemProperty -Path "HKLM:\Software\Policies\Google\Update\" -Name ProxyMode -Type String -Value "fixed_servers"
Set-ItemProperty -Path "HKLM:\Software\Policies\Google\Update\" -Name ProxyServer -Type String -Value "us-east-1.r2d2hostedzone:3128"




#Put Mozzilla Stuff in Place
Copy-Item -Destination 'C:\Program Files\Mozilla Firefox\defaults\pref\' -Path "${r2d2path}\firefox\autoconfig.js" -Force
Copy-Item -Destination 'C:\Program Files\Mozilla Firefox\' -Path "${r2d2path}\firefox\mozilla.cfg" -Force
Copy-Item -Destination 'C:\AutoConfig\' -Path "${r2d2path}\firefox\mozilla.cfg" -Force
Copy-Item -Destination C:\AutoConfig\ -Path "${r2d2path}\firefox\permissions.sqlite"
Copy-Item -Destination C:\AutoConfig\ -Path "${r2d2path}\firefox\places.sqlite"
Copy-Item -Destination C:\AutoConfig\ -Path "${r2d2path}\firefox\xulstore.json"
Copy-Item -Destination C:\AutoConfig\ -Path "${r2d2path}\firefox\extensions" -Recurse


#Shortcut icons
Copy-Item -Destination C:\Shortcuts\ -Path "${r2d2path}\firefox\firefoxicon.png"
Copy-Item -Destination C:\Shortcuts\ -Path "${r2d2path}\chrome\chromeicon.png"

#Mozilla Extensions
New-Item -Path "C:\Program Files\Mozilla Firefox\browser\" -ItemType Directory -Name "extensions" -Force
Copy-Item -Destination "C:\Program Files\Mozilla Firefox\browser\extensions" -Path "${r2d2path}\firefox\extensions\*" -Recurse -Force



#CookieGuard
Copy-Item -Destination C:\AppStream\SessionScripts -Path "${r2d2path}\CookieGuard\*" -Recurse -Force


#Splunk
Start-Process msiexec.exe -Wait -ArgumentList '/I C:\deployment\splunkforwarder.msi AGREETOLICENSE=Yes /quiet'
Copy-Item -Path 'C:\Deployment\appstream\SplunkForwarder\*' -Destination 'C:\Program Files\SplunkUniversalForwarder\etc\system\local\' -Recurse -Force



#Copy RegionSwitcher to AutoConfig
Copy-Item -Path "${r2d2path}\RegionSwitcher\*" -Destination "C:\AutoConfig\" -Recurse -Force

#Copy TimeZone Service to AutoConfig
Copy-Item -Path "$r2d2path\TimeZone\TimeZone*" -Destination "C:\AutoConfig\" -Recurse -Force


Copy-Item -Path "C:\AutoConfig\mozilla.cfg" -Destination "C:\Program Files\Mozilla Firefox\" -Force

#Set Folder Permissions
$files = @("C:\Program Files\Mozilla Firefox\mozilla.cfg","C:\AutoConfig\First Run","C:\AutoConfig\mozilla.cfg")
$files | % {
    $path = $_
    $acl = Get-Acl $path
    $AccessRule = New-Object System.Security.AccessControl.FileSystemAccessRule("BUILTIN\Users","FullControl", "None","None","Allow")
    $acl.SetAccessRule($AccessRule)
    $acl | Set-Acl $path
}

$paths = @("C:\Shortcuts\","C:\BrowserData\")
$paths | % {
    $path = $_
    $acl = Get-Acl $path
    $AccessRule = New-Object System.Security.AccessControl.FileSystemAccessRule("BUILTIN\Users","FullControl", "ContainerInherit, ObjectInherit","None","Allow")
    $acl.SetAccessRule($AccessRule)
    $acl | Set-Acl $path
}



#Set Registry Permissions
$regPath = "HKLM:\Software\Policies\Google\Chrome\"

$regAcl = Get-Acl $regPath
$regAccessRule = New-Object System.Security.AccessControl.RegistryAccessRule("BUILTIN\Users","FullControl", "ContainerInherit, ObjectInherit","None","Allow")
$regAcl.AddAccessRule($regAccessRule)
$regAcl | Set-Acl $regPath



#Install Time Zone Service
Register-ScheduledTask -Xml (Get-Content 'C:\AutoConfig\TimeZone.xml' | Out-String) -TaskName "TimeZone" -User "SYSTEM"



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
# Data directories for chrome and firefox, and the root folder
[string]$Script:FirefoxDataDir = 'C:\BrowserData\Firefox'
[string]$Script:ChromeDataDir = 'C:\BrowserData\Chrome'
[string]$Script:RootDataDir = 'C:\BrowserData'

# Where to write the timezone update 
[string]$Script:TimeZoneUpdateFile = 'C:\AutoConfig\TimeZoneUpdate.txt'

# Likely these can be combined
# Is the profile read only?
[string]$Script:ProfileReadOnly = $False
# Are we using minified profiles?
[string]$Script:MinifiedProfile = $False

# Variables we need to set to use the S3 Bucket and IAM role
$env:AWS_PROFILE='appstream_machine_role'
$s3bucket = 'r2d2-profile'

# The homepage we will use
$r2d2homepage = "https://r2d2-launcher-nonprod.s3.amazonaws.com"

# Copy the Firefox extensions
function CopyFFExtentions(){
    Copy-Item -Path "C:\AutoConfig\extensions" -Destination "C:\BrowserData\Firefox" -Recurse -Force
}

# The main function we use
function ChangeRegionAndProfile($proxyConnectionString, $language, $timezone,$oldProfile,$newProfile, $proxy){
    Write-Host "Received Variables"
    Write-Host "proxyConnectionString: $proxyConnectionString"
    Write-Host "language $language"
    Write-Host "timezone $timezone"
    Write-Host "oldProfile $oldProfile"
    Write-Host "newProfile $newProfile"

    # Kill all browsers before switching anything
    # Assures no files will be locked
    KillAllBrowsers

    # If we are using profiles, upload the old one so its data can be saved
    if($Script:ProfileReadOnly -eq $False -and $oldProfile -ne ''){
      UploadOldProfiles -oldProfile $oldProfile
    }

    # Change the timezone
    ChangeTimezone -timezone $timezone

    # if we are NOT using profiles, we can clear all the data
    if($newProfile -eq '' -or $Script:MinifiedProfile -eq $True){
      ClearChromeCache
      ClearFirefoxCache
    }
    
    # Copy the Firefox extensions, since they need to be in the data directory
    CopyFFExtentions

    #Change Chrome Language
    ChangeChromeLanguage -language $language
    #Change Chrome Proxy
    ChangeChromeProxy -connectionString $proxyConnectionString
    # Change firefox proxy and language
    ChangeFirefoxProxyAndLanguage -language $language -proxy $proxyConnectionString

    # If profiles are enabled, then go download the new one
    if ($newProfile -ne ''){
          DownloadProfiles -newProfile $newProfile
    }

    # Update the shortcuts so the region can be displayed
    CreateShortcuts -proxy $proxy
}


# loop through all threads/processes for the any process that contians the browser names
# Then kill those processes
function KillAllBrowsers(){
  $processes = Get-Process
  $totalProcesses = 1
  while($totalProcesses -gt 0){
      $totalProcesses = 0
      $processes = Get-Process

      $chrome = $processes | ? {$_.ProcessName -eq 'chrome'}
      $totalProcesses = $totalProcesses + $chrome.Count
      $chrome | %{$_.Kill()}

      $firefox = $processes | ? {$_.ProcessName -eq 'firefox'}
      $totalProcesses = $totalProcesses + $firefox.Count
      $firefox | %{$_.Kill()}

      $iexplore = $processes | ? {$_.ProcessName -eq 'iexplore'}
      $totalProcesses = $totalProcesses + $iexplore.Count
      $iexplore | %{$_.Kill()}
      Start-Sleep -Seconds 1
  }
}

# Delete all the files in the firefox data directory
# Put specific configuration files in
function ClearFirefoxCache(){
    Remove-Item -Path $Script:FirefoxDataDir -Force -Recurse
    New-Item -Path $Script:FirefoxDataDir -Force -ItemType "directory"
    Copy-Item -Path "C:\AutoConfig\permissions.sqlite" -Destination $Script:FirefoxDataDir
    Copy-Item -Path "C:\AutoConfig\places.sqlite" -Destination $Script:FirefoxDataDir
    Copy-Item -Path "C:\AutoConfig\xulstore.json" -Destination $Script:FirefoxDataDir
}

# Since both proxy and language are in the same config file,
# Combine the functions to change them
function ChangeFirefoxProxyAndLanguage([string] $language, [string] $proxy){
    $lowerLanguage = $language.ToLower()
    $proxyIP = ($proxy -split ":")[0]
    $proxyPort = ($proxy -split ":")[1]

    $ffconfig = Get-Content -Path 'C:\AutoConfig\mozilla.cfg' -Raw
    $modConfig = $ffconfig | % {
        $modVal = $_
        $modVal = $modVal -replace '__PROXYIP__',   $proxyIP
        $modVal = $modVal -replace '__PROXYPORT__', $proxyPort
        $modVal = $modVal -replace '__LANGUAGE__',  $lowerLanguage
        $modVal
    }
    Set-Content -Path 'C:\Program Files\Mozilla Firefox\mozilla.cfg' -Value $modConfig -Force
}

# Set the registry key for the chrome proxy
function ChangeChromeProxy([string]$connectionString){
    $dataToSet = "{`"ProxyMode`":`"fixed_servers`",`"ProxyServer`":`"${connectionString}`",`"ProxyBypassList`": `"${r2d2homepage}`"}"
    Set-ItemProperty -Path "HKLM:\Software\Policies\Google\Chrome\" -Name "ProxySettings" -Value $dataToSet
}

# Delete the files in the chrome data directory
# Make sure the first run file is in place
function ClearChromeCache(){
    Copy-Item -Path "$Script:ChromeDataDir\First Run" -Destination "C:\AutoConfig" -Force
    Remove-Item $Script:ChromeDataDir -Recurse -Force
    New-Item -Path $Script:ChromeDataDir -Force -ItemType "directory"
    Copy-Item -Path "C:\AutoConfig\First Run" -Destination $Script:ChromeDataDir -Force
}

# Following functions lock and unlock the profiles
# I dont remember why the same functions exist in the GUI

function LockProfile([string] $profileName){
    echo $null >> "${profileName}.lock"
    aws s3 cp "${profileName}.lock" "s3://${s3bucket}"
}

function UnlockProfile([string] $profileName){
    aws s3 rm "s3://${s3bucket}/${profileName}.lock"
}

# Writes the timezone to the TimeZoneUpdateFile
function ChangeTimezone([string] $timezone){
  $timezone >> $Script:TimeZoneUpdateFile
}

# Chrome language is controlled by a file in the chrome directory
function ChangeChromeLanguage([string] $language){
  New-Item -path "$Script:ChromeDataDir\Default" -Force -ItemType "directory"
  ((Get-Content -path C:\AutoConfig\Preferences.tmp -Raw) -replace '__LANGUAGE__',$language) |`
      Set-Content -Path "$Script:ChromeDataDir\Default\Preferences" -Encoding ASCII
}

# Updates/Creates the bat shortcuts to call the browsers with the flags and homepage
function CreateShortcuts([string] $proxy){
  $chromeText = "start `"Chrome`" `"C:\Program Files\Google\Chrome\Application\chrome.exe`" --new-window --disable-signin-promo --no-first-run --disable-sync --start-maximized ${r2d2homepage}/homepage.html?proxy="
  $firefoxText = "start `"Firefox`" `"C:\Program Files\Mozilla Firefox\firefox.exe`"  -profile `"C:\BrowserData\Firefox`" -new-window ${r2d2homepage}/homepage.html?proxy="

  $proxy = $proxy.Replace(" ","+")

  $chromeText += $proxy
  $firefoxText += $proxy

  Set-Content "C:\Shortcuts\chrome.bat" "${chromeText}" -Encoding ASCII
  Set-Content "C:\Shortcuts\firefox.bat" "${firefoxText}" -Encoding ASCII
}

# Uploads the profile folder
function UploadFolder([string] $folder, [string] $name){
    Compress-Archive -Path "$folder" -DestinationPath "${name}.zip" -Force
    echo "Done Compressing" >> "C:\AutoConfig\temp.txt"
    aws s3 cp "${name}.zip" "s3://${s3bucket}" --quiet
    if(Test-Path "${folder}"){
        Remove-Item -Path "${folder}" -Recurse -Force
    }
    
}

# Uploads both chrome and firefox profiles
function UploadOldProfiles([string] $oldProfile){
    if ($Script:ProfileReadOnly -eq $True) {
      UnlockProfile -profileName $oldProfile
      return
    }
    UploadFolder -folder $Script:ChromeDataDir -name "${oldProfile}_Chrome"
    UploadFolder -folder $Script:FirefoxDataDir -name $oldProfile
    UnlockProfile -profileName $oldProfile
}

# Downloads the profiles
function DownloadFolder([string] $folder, [string] $name){
    if(Test-Path "${folder}/${name}.zip"){
        Remove-Item -Path "${folder}/${name}.zip" -Recurse -Force
    }
    aws s3 cp "s3://${s3bucket}/${name}.zip" "${folder}/${name}.zip" --quiet
    Expand-Archive -Path "${folder}/${name}.zip" -DestinationPath "${folder}" -Force
}

# Downloads both chrome and firefox profiles
function DownloadProfiles([string] $newProfile){
    if ($Script:ProfileReadOnly -ne $True){
      LockProfile -profileName $newProfile
    }
    DownloadFolder -folder $Script:RootDataDir -name $newProfile
    DownloadFolder -folder $Script:RootDataDir -name "${newProfile}_Chrome"
}

# Deletes firefox lock file
function Unlock-Firefox([string] $profileName){
    if (Test-Path "$Script:FirefoxProfilePath\${profileName}\parent.lock"){
        Remove-Item -Path "$Script:FirefoxProfilePath\${profileName}\parent.lock" -Force
    }
}
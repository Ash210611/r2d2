# PowerShell script to apply Firefox policies on Windows

# Define policies for Firefox
$homepage = "https://www.example.com"
$disablePrivateBrowsing = 1
$blockedHosts = @("http://www.example1.com", "http://www.example2.com")
$allowedHosts = @("http://www.allowedexample.com")

# Define the registry path for Firefox policies
$registryPath = "HKLM:\SOFTWARE\Policies\Mozilla\Firefox"

# Ensure the Firefox policies registry path exists
if (-not (Test-Path $registryPath)) {
    New-Item -Path $registryPath -Force
}

# Set Homepage
Set-ItemProperty -Path $registryPath -Name "Homepage" -Value $homepage -Type String

# Disable Private Browsing
Set-ItemProperty -Path $registryPath -Name "DisablePrivateBrowsing" -Value $disablePrivateBrowsing -Type DWord

# Block access to a list of URLs
$blockedHostsPath = "$registryPath\BlockedHosts"
if (-not (Test-Path $blockedHostsPath)) {
    New-Item -Path $blockedHostsPath -Force
}
for ($i = 0; $i -lt $blockedHosts.Count; $i++) {
    New-ItemProperty -Path $blockedHostsPath -Name "$i" -Value $blockedHosts[$i] -PropertyType String -Force
}

# Allow specific URLs
$allowedHostsPath = "$registryPath\AllowedHosts"
if (-not (Test-Path $allowedHostsPath)) {
    New-Item -Path $allowedHostsPath -Force
}
for ($i = 0; $i -lt $allowedHosts.Count; $i++) {
    New-ItemProperty -Path $allowedHostsPath -Name "$i" -Value $allowedHosts[$i] -PropertyType String -Force
}

Write-Output "Firefox policies have been applied successfully on Windows."
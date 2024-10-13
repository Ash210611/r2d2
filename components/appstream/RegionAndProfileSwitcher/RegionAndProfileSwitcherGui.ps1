# Importing this to make it convenient to use the objects in here
using namespace System.Windows.Forms

# Import the library
. C:\AutoConfig\RegionAndProfileSwitcherLibrary.ps1

# Allows us to minimize the cmd window that pops up
Add-Type -Name Window -Namespace Console -MemberDefinition '
[DllImport("Kernel32.dll")]
public static extern IntPtr GetConsoleWindow();

[DllImport("user32.dll")]
public static extern bool ShowWindow(IntPtr hWnd, Int32 nCmdShow);
'
# Other imports we need to make it look right
Add-Type -AssemblyName PresentationCore,PresentationFramework
Add-Type -AssemblyName System.Windows.Forms
[System.Windows.Forms.Application]::EnableVisualStyles()

# Makes sure the GUI is uniquely running
(Get-Process)| ?{$_.MainWindowTitle  -eq "Select Your Region" -and $_.Id -ne $PID} | % {$_.Kill()}

# Variables we need to use the s3 bucket for profiles
$env:AWS_PROFILE='appstream_machine_role'
$s3bucket = 'r2d2-profile'

# Enables or disables profiles
[boolean]$Script:ProfilesActive=$True

# Variables to adjust height/widths of gui components
[string]$Script:NoProfileWidthSubtracter = 200 
[string]$Script:SelectedProfile = ''
[string]$Script:SelectedRegion = ''
[string]$Script:LastProfile = ''
[string]$Script:LastRegion = ''
[int]$Script:RegionListXLocation = 50
[int]$Script:ProfileListXLocation = 10
[int]$Script:ButtonSpacing = 25
[int]$Script:RegionRadioButtonStartPosition = 10
[int]$Script:ProfileRadioButtonStartPosition = -10
[int]$Script:FormPadding = 60
[int]$Script:GroupBoxVerticalPadding = 15
[int]$Script:GroupBoxWidth = 200
[int]$Script:GroupBoxHeight= 0
[string]$Script:RegionGroupBoxLocation = '40,30'
[string]$Script:ProfileGroupBoxLocation = '250,30'
[int]$Script:LabelDelta = 10

# File Location Variables
[string]$Script:RegionConfigFile = "C:\AutoConfig\ProxyConfig.csv"
[string]$Script:ProfileConfigFile = "C:\AutoConfig\ProfilesList.csv"
[string]$Script:LastProfileFile = "C:\Profiles\LastProfile.txt"
[string]$Script:LastRegionFile = "C:\Users\Public\history.txt"
[string]$Script:HomepageSiteHistory = "C:\inetpub\wwwroot\history.txt"

# Global variables for GUI
# If this was OO, these and all the above would be fields or other things
[Hashtable]$Script:RegionConfiguration = @{}
[Object[]]$Script:RegionRadioButtons = @()
[RadioButton[]]$Script:ProfileRadioButtons = (New-Object RadioButton[] 0)
[Form]$Script:Form = (New-Object Form)
[GroupBox]$Script:ProfileGroupBox = (New-Object GroupBox)
[Button]$Script:OkButton                         = New-Object system.Windows.Forms.Button
[Button]$Script:CancelButton                     = New-Object system.Windows.Forms.Button

# Gets the Content of the RegionConfigFile
$Script:RegionFileContent = Get-Content $Script:RegionConfigFile

# Put the GUI together
function BuildGui(){
    GetPreviouslySetProfileAndRegion
    GenerateRegionRadioButtons
    BuildForm
    GenerateRegionGroupBox
    ReadProfileConfig
    AddLabels
    AddButtons
    ReDrawProfiles
    $Script:Form.ShowDialog()
    $Script:Form.Dispose()
}

# Lock the profile by uploading the lock file to the S3 Bucket
function LockProfile([string] $profileName){
    echo $null >> "${profileName}.lock"
    aws s3 cp "${profileName}.lock" "s3://${s3bucket}"
}

# Determines if the Profile is locked
function IsProfileLocked([string] $profileName){
    $output = aws s3 ls "s3://${s3bucket}/${profileName}.lock"
    $toRet = $output -ne $null
    Write-Host "$profileName locked status: $toRet"
    return $toRet 
}

# Meaning either Profile is unlocked
# Or we have the lock
function IsProfileSwitchableTo(){
    if($Script:SelectedProfile -eq $Script:LastProfile){
        return $true
    }
    $toRet = (IsProfileLocked -profileName $Script:SelectedProfile) -ne $true
    Write-Host "Can we switch to $Script:SelectedProfile : $toRet"
    return $toRet
}

# gets the selected regions configuration data
function GetSelectedRegionConfig(){
    foreach ($RegionLine in $Script:RegionFileContent){
        if ($RegionLine -like "*$Script:SelectedRegion*"){
            return ($RegionLine -split ',').Trim()
        } 
    }
}

# Gets the previous settings, so the GUI can display them already checked
function GetPreviouslySetProfileAndRegion(){
    if (Test-Path $Script:LastProfileFile){
        $Script:SelectedProfile = Get-Content $Script:LastProfileFile
        $Script:LastProfile = $Script:SelectedProfile
    }
    if (Test-Path $Script:LastRegionFile){
        $Script:SelectedRegion = Get-Content $Script:LastRegionFile
        $Script:LastRegion = $Script:SelectedRegion
    }

    Write-Host $Script:SelectedRegion
    Write-Host $Script:SelectedProfile
    Write-Host "Above are what we read"
}

# Updates the last files, so we can use them next time the GUI runs
function UpdateLastRegionAndProfileFiles(){
    Write-Host "Updating Files"
    $Script:SelectedRegion > $Script:LastRegionFile
    #$Script:SelectedRegion > $Script:HomepageSiteHistory
    $Script:SelectedProfile > $Script:LastProfileFile

    Write-Host "Selected Region: $Script:SelectedRegion"
    Write-Host "Selected Profile $Script:SelectedProfile"
}

# Creates the Group Box where the regions will be displayed
function GenerateRegionGroupBox(){
    $RegionGroupBox = New-Object GroupBox
    $RegionGroupBox.Location = $Script:RegionGroupBoxLocation
    $RegionGroupBox.Width = $Script:GroupBoxWidth
    $RegionGroupBox.Height = $Script:GroupBoxHeight

    $RegionGroupBox.Controls.AddRange($Script:RegionRadioButtons)
    $Script:Form.Controls.Add($RegionGroupBox)
}

# Initializes the whole form, 
function BuildForm(){
    $formHeight = $Script:ButtonSpacing*$Script:RegionRadioButtons.Length+$Script:FormPadding
    $Script:GroupBoxHeight = $Script:ButtonSpacing*$Script:RegionRadioButtons.Length+ $Script:GroupBoxVerticalPadding

    $Script:Form.ClientSize                 = "650,$formHeight"
    $Script:Form.text                       = "Select Your Region"
    $Script:Form.TopMost                    = $false
    $Script:Form.BackColor                  = "white"
    $Script:Form.MinimizeBox                = $false
    $Script:Form.MaximizeBox                = $false

    if($Script:ProfilesActive -eq $false){
        $Script:Form.Width = $Script:Form.Width - $Script:NoProfileWidthSubtracter
    }
}

# Updates the Selected Region to the value clicked
# Should be called off of an click event (not directly, but via another function)
function UpdateSelectedRegion([string]$buttonClicked){
    $Script:SelectedRegion  = $buttonClicked
}
# Updates the Selected Profile to the value clicked
# Should be called off of an click event (not directly, but via another function)
function UpdateSelectedProfile([string]$buttonClicked){
    $Script:SelectedProfile  = $buttonClicked
}


# Reads and populates the profile configuration
function ReadProfileConfig(){

    if($Script:ProfilesActive -eq $false){
        return
    }

    $profileList = Get-Content $Script:ProfileConfigFile
    foreach($profileLine in $profileList){
        $profileConf = $profileLine -split ','
        $profileName = $profileConf[0]
        $profileRegion = $profileConf[1]

        $profileButton = New-Object system.Windows.Forms.RadioButton
        $profileButton.text               = $profileName
        $profileButton.Tag                = $profileRegion
        $profileButton.AutoSize           = $true
        $profileButton.width              = 104
        $profileButton.height             = 20
        $profileButton.Font               = 'Microsoft Sans Serif,12'
        $profileButton.Add_Click({
            UpdateSelectedProfile -buttonClicked $this.text
        })
        $Script:ProfileRadioButtons += $profileButton
    } 
}

# Ands the labels to the form, where we see the Egress and profile labels 
function AddLabels(){
    $EgressLabel = New-Object System.Windows.Forms.Label
    $EgressLabel.Text = "Egress"
    $EgressLabel.size = "150,100"
    $EgressLabel.Location = '40,0'
    $EgressLabel.Font                    = 'Microsoft Sans Serif,20'
    $EgressLabel.ForeColor               = 'black'

    $Script:Form.Controls.Add($EgressLabel)

    if($Script:ProfilesActive -eq $false){
        return
    }

    $ProfileLabel = New-Object System.Windows.Forms.Label
    $ProfileLabel.Text = "Profile"
    $ProfileLabel.size = "150,100"
    $ProfileLabel.Location = '250,0'
    $ProfileLabel.Font                    = 'Microsoft Sans Serif,20'
    $ProfileLabel.ForeColor               = 'black'

    $Script:Form.Controls.Add($ProfileLabel)
}


# This function gets called whenever the OK button is pressed
function OkButtonFunc(){
    Write-Host "Ok Button Pressed"
    
    # Makes sure we can actually switch to the active profile
    if($Script:ProfilesActive -eq $true){
        $outVal = IsProfileSwitchableTo
        Write-Host $outVal
        if($outVal -eq $false){
            [System.Windows.MessageBox]::Show('Profile is Locked. Please choose a different Profile.')
            return
        }
    }

    # Final check to make sure the user is ready to switch
    $result = [System.Windows.Forms.MessageBox]::Show("Switching to $Script:SelectedRegion`r`nContinue?", 'Confirm Switch', 'YesNo')
    if($result -eq 'No'){
        return
    }

    # Change the button to grey, showing we are working on it
    $Script:OkButton.Enabled = $false
    $Script:OkButton.BackColor = 'red'
    $Script:OkButton.text = "Please Wait"
    $Script:CancelButton.Enabled = $false

    # Update our last region and profile
    UpdateLastRegionAndProfileFiles

    $RegionConfig = GetSelectedRegionConfig
    $proxyRegion = $RegionConfig[0]
    $connectionString = $RegionConfig[1]
    $language = $RegionConfig[2]
    $timezone = $RegionConfig[3]

    # Actually call the library 
    ChangeRegionAndProfile  -proxyConnectionString $connectionString -language $language -timezone $timezone -oldProfile $Script:LastProfile -newProfile $Script:SelectedProfile -proxy $proxyRegion

    # Change the button back to normal
    $Script:OkButton.Enabled = $true
    $Script:OkButton.BackColor = 'lightgray'
    $Script:OkButton.text = "OK"
    $Script:CancelButton.Enabled = $true

    [System.Windows.MessageBox]::Show('Egress is set to '+ $Script:SelectedRegion +`
                                      '. Please Open Browser Now.','Egress setup')

    $Script:Form.Close()

}


# Runs when the cancel button is pressed
function CancelButtonFunc(){
    Write-Host "Cancel Button Pressed"
    $Script:Form.Close()
}


# Adds all the buttons to the form
function AddButtons(){
    
    $Script:OkButton.text                    = "OK"
    $Script:OkButton.width                   = 150
    $Script:OkButton.height                  = 75
    $Script:OkButton.location                = New-Object System.Drawing.Point(460,50)
    $Script:OkButton.Font                    = 'Microsoft Sans Serif,20'
    $Script:OkButton.ForeColor               = 'Red'
    $Script:OkButton.BackColor               = 'lightgray'


    $Script:CancelButton                     = New-Object system.Windows.Forms.Button
    $Script:CancelButton.text                = "Cancel"
    $Script:CancelButton.width               = 150
    $Script:CancelButton.height              = 50
    $Script:CancelButton.location            = New-Object System.Drawing.Point(460,150)
    $Script:CancelButton.Font                = 'Microsoft Sans Serif,20'
    $Script:CancelButton.ForeColor           = 'Blue'
    $Script:CancelButton.BackColor           = 'lightgray'

    if($Script:ProfilesActive -eq $false){
        $Script:OkButton.location            = New-Object System.Drawing.Point((460-$Script:NoProfileWidthSubtracter),50)
        $Script:CancelButton.location        = New-Object System.Drawing.Point((460-$Script:NoProfileWidthSubtracter),150)
    }

    $Script:OkButton.Add_Click({ OkButtonFunc })
    $Script:CancelButton.Add_Click({ CancelButtonFunc })

    $Script:Form.Controls.Add($Script:OkButton)
    $Script:Form.Controls.Add($Script:CancelButton)
}


# When a new region is selected, we need to display a different list of profiles
# So we re-draw them based on the selected region
function ReDrawProfiles(){

    if($Script:ProfilesActive -eq $false){
        return
    }

    $Script:Form.Controls.Remove($Script:ProfileGroupBox)
    $Script:ProfileGroupBox = New-Object GroupBox
    $Script:ProfileGroupBox.Location = $Script:ProfileGroupBoxLocation
    $Script:ProfileGroupBox.Width = $Script:GroupBoxWidth
    $Script:ProfileGroupBox.Height = $Script:GroupBoxHeight


    $ProfileRadioButtonPos = 1

    foreach($ProfileRadioButton in $Script:ProfileRadioButtons){

        if ($ProfileRadioButton.Tag -eq $Script:SelectedRegion){
            $ProfileRadioButton.Location = New-Object System.Drawing.Point(($Script:ProfileListXLocation),`
                                ($Script:ProfileRadioButtonStartPosition+$ProfileRadioButtonPos*$Script:ButtonSpacing))

            $ProfileRadioButtonPos = $ProfileRadioButtonPos +1 

            if($ProfileRadioButton.Text -eq $Script:SelectedProfile){
                $ProfileRadioButton.Checked = $true
            }else{
                $ProfileRadioButton.Checked = $false
            }

            $Script:ProfileGroupBox.Controls.Add($ProfileRadioButton)
        }
    }
    $Script:Form.Controls.Add($Script:ProfileGroupBox)
    $Script:ProfileGroupBox.BringToFront()
}


# Generates the radio buttons for the regions
function GenerateRegionRadioButtons(){
    $RegionListPosition = 0
    foreach($RegionLine in $Script:RegionFileContent){
        $RegionConf = $RegionLine -split ','
        $RegionName = $RegionConf[0]
        $RegionToAdd = $null
        $toSubtract = 0
        if($RegionConf.Length -eq 1){
            $RegionToAdd = New-Object Label
            $toSubtract = $Script:LabelDelta
        }else{
            $RegionToAdd = New-Object RadioButton
            $RegionToAdd.Add_Click({
                UpdateSelectedRegion -buttonClicked $this.Text
                ReDrawProfiles
            })
        }

        
        $RegionToAdd.Location = New-Object System.Drawing.Point(($Script:RegionListXLocation-$toSubtract),`
                                ($Script:RegionRadioButtonStartPosition+$RegionListPosition*$Script:ButtonSpacing))
        $RegionToAdd.text               = $RegionName
        $RegionToAdd.AutoSize           = $true
        $RegionToAdd.width              = 104
        $RegionToAdd.height             = 20
        $RegionToAdd.Font               = 'Microsoft Sans Serif,12'

        if($RegionToAdd.text -eq $Script:SelectedRegion){
            $RegionToAdd.Checked = $true
        }

        $Script:RegionRadioButtons += $RegionToAdd
        $RegionListPosition = $RegionListPosition +1
    }
}

# Minimizes the CMD window
$sig='[DllImport("user32.dll")] public static extern bool ShowWindowAsync(IntPtr hWnd, int nCmdShow);'
Add-Type -MemberDefinition $sig -name NativeMethods -namespace Win32
$PSId = (Get-Process | ? { $_.MainWindowTitle -like "*RegionAndProfileSwitcherGui*"})[0].MainWindowHandle
[Win32.NativeMethods]::ShowWindowAsync($PSId,2)


# Call our Main
BuildGui


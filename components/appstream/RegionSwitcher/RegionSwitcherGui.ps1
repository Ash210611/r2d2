# Importing this to make it convenient to use the objects in here
using namespace System.Windows.Forms

# Import the library
. C:\AutoConfig\RegionSwitcherLibrary.ps1

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

# Variables to adjust height/widths of gui components
[string]$Script:SelectedRegion = ''
[string]$Script:LastRegion = ''
[int]$Script:RegionListXLocation = 20
[int]$Script:ButtonSpacing = 20
[int]$Script:RegionRadioButtonStartPosition = -10
[int]$Script:FormPadding = 30
[int]$Script:GroupBoxVerticalPadding = 30
[int]$Script:GroupBoxWidth = 340
[int]$Script:GroupBoxHeight= 0
[string]$Script:RegionGroupBoxLocation = '40,25'
[int]$Script:LabelDelta = 40

# File Location Variables
[string]$Script:RegionConfigFile = "C:\AutoConfig\ProxyConfig.csv"
[string]$Script:LastRegionFile = "C:\Users\Public\history.txt"

# Global variables for GUI
# If this was OO, these and all the above would be fields or other things
[Hashtable]$Script:RegionConfiguration = @{}
[Object[]]$Script:RegionRadioButtons = @()
[checkbox]$Script:RegionLangOverrideCB = New-Object system.Windows.Forms.CheckBox
[Form]$Script:Form = (New-Object Form)
[Button]$Script:OkButton = New-Object system.Windows.Forms.Button
[Button]$Script:CancelButton = New-Object system.Windows.Forms.Button

# Gets the Content of the RegionConfigFile
$Script:RegionFileContent = Get-Content $Script:RegionConfigFile

# Put the GUI together
function BuildGui(){
    GetPreviouslySetRegion
    GenerateRegionRadioButtons
    BuildForm
    GenerateRegionGroupBox
    AddLabels
    AddLanguageOverride
    AddButtons
    $Script:Form.ShowDialog()
    $Script:Form.Dispose()
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
function GetPreviouslySetRegion(){
   if (Test-Path $Script:LastRegionFile){
        $SavedFileContent = Get-Content $Script:LastRegionFile
        $SavedSettings = $SavedFileContent -split ' - '
        $Script:SelectedRegion = $SavedSettings[0]
        $Script:LastRegion = $Script:SelectedRegion 
        if ($SavedSettings[1] = 'Language Override'){
            $Script:RegionLangOverrideCB.Checked = $true
        }else{
            $Script:RegionLangOverrideCB.Checked = $false
        }
    }

    Write-Host "*Read from history file: $SavedFileContent"

}

# Updates the last files, so we can use them next time the GUI runs
function UpdateLastRegionFiles(){
    Write-Host "*Updating Files"
    if ($Script:RegionLangOverrideCB.Checked){
        $langOverride = ' - Language Override'
    }
    $Script:SelectedRegion + $langOverride > $Script:LastRegionFile

    Write-Host "Selected Region: $Script:SelectedRegion, Language Override: $Script:RegionLangOverrideCB"
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
    $Script:GroupBoxHeight = $Script:GroupBoxHeight + $Script:GroupBoxVerticalPadding
    $formHeight = $Script:GroupBoxHeight + $Script:FormPadding

    #Sets the starting position of the form at run time.
    $CenterScreen = [System.Windows.Forms.FormStartPosition]::CenterScreen;

    $Script:Form.StartPosition              = $CenterScreen;
    $Script:Form.ClientSize                 = "650,$formHeight"
    $Script:Form.text                       = "Select Your Region"
    $Script:Form.TopMost                    = $false
    $Script:Form.BackColor                  = "white"
    $Script:Form.MinimizeBox                = $false
    $Script:Form.MaximizeBox                = $false
}

# Updates the Selected Region to the value clicked
# Should be called off of an click event (not directly, but via another function)
function UpdateSelectedRegion([string]$buttonClicked){
    $Script:SelectedRegion  = $buttonClicked
}

# Ands the labels to the form, where we see the Egress and profile labels 
function AddLabels(){
    $EgressLabel = New-Object System.Windows.Forms.Label
    $EgressLabel.Text = "Egress"
    $EgressLabel.size = "120,60"
    $EgressLabel.Location = '40,0'
    $EgressLabel.Font                    = 'Microsoft Sans Serif,16'
    $EgressLabel.ForeColor               = 'black'

    $Script:Form.Controls.Add($EgressLabel)
}


# This function gets called whenever the OK button is pressed
function OkButtonFunc(){
    Write-Host "Ok Button Pressed"
    
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
    UpdateLastRegionFiles

    $RegionConfig = GetSelectedRegionConfig
    $proxyRegion = $RegionConfig[0]
    $connectionString = $RegionConfig[1]
    $language = $RegionConfig[2]
    $timezone = $RegionConfig[3]

    if($Script:RegionLangOverrideCB.Checked -eq $true){
        $language = 'en'
    }

    Write-Output "$language, $timezone"

    # Actually call the library 
    ChangeRegion -proxyConnectionString $connectionString -language $language -timezone $timezone -proxy $proxyRegion

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


# Add language override checkbox
function AddLanguageOverride(){

    $Script:RegionLangOverrideCB.text = "World English Language Override"
    $Script:RegionLangOverrideCB.Width = 200
    $Script:RegionLangOverrideCB.Height = 60
    $Script:RegionLangOverrideCB.Location = New-Object System.Drawing.Point(450,300)
    $Script:RegionLangOverrideCB.Font = 'Microsoft Sans Serif,12'
    $Script:RegionLangOverrideCB.TextAlign = 'BottomLeft'

    $Script:Form.Controls.Add($Script:RegionLangOverrideCB) 
}

# Adds all the buttons to the form
function AddButtons(){
    
    $Script:OkButton.text                    = "OK"
    $Script:OkButton.width                   = 150
    $Script:OkButton.height                  = 70
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

    $Script:OkButton.Add_Click({ OkButtonFunc })
    $Script:CancelButton.Add_Click({ CancelButtonFunc })

    $Script:Form.Controls.Add($Script:OkButton)
    $Script:Form.Controls.Add($Script:CancelButton)
}

# Generates the radio buttons for the regions
function GenerateRegionRadioButtons(){
    $RegionListPosition = 0
    $RegionListColumn = 0
    $RegionPositionX = $Script:RegionListXLocation
    $RegionPositionY = $Script:RegionRadioButtonStartPosition
    foreach($RegionLine in $Script:RegionFileContent){
        $RegionConf = $RegionLine -split ','
        $RegionName = $RegionConf[0]
        $RegionToAdd = $null
        if($RegionConf.Length -eq 1){
            $RegionToAdd = New-Object Label
            $RegionListColumn = 1
            $RegionPositionX = $Script:RegionListXLocation 
            $RegionPositionY = $RegionPositionY + $Script:ButtonSpacing
            $RegionToAdd.text = $RegionName + " -"
            $RegionToAdd.Font = 'Microsoft Sans Serif,12'
            $RegionToAdd.ForeColor = "blue"
        }else{
            $RegionToAdd = New-Object RadioButton
            $RegionPositionY = $RegionPositionY + $RegionListColumn *  $Script:ButtonSpacing
            $RegionListColumn = 1 - $RegionListColumn
            $RegionPositionX = $Script:RegionListXLocation + $RegionListColumn * 150 + $Script:LabelDelta
            $RegionToAdd.text = $RegionName
            $RegionToAdd.Font = 'Microsoft Sans Serif,11'
            $RegionToAdd.Add_Click({
                UpdateSelectedRegion -buttonClicked $this.Text
            })
        }

        
        $RegionToAdd.Location = New-Object System.Drawing.Point($RegionPositionX,$RegionPositionY)
        $RegionToAdd.AutoSize           = $true
        $RegionToAdd.width              = 120
        $RegionToAdd.height             = 20

        if($RegionToAdd.text -eq $Script:SelectedRegion){
            $RegionToAdd.Checked = $true
        }

        $Script:RegionRadioButtons += $RegionToAdd
        $RegionListPosition = $RegionListPosition +1
    }
    $Script:GroupBoxHeight = $RegionPositionY
}

# Minimizes the CMD window
$sig='[DllImport("user32.dll")] public static extern bool ShowWindowAsync(IntPtr hWnd, int nCmdShow);'
Add-Type -MemberDefinition $sig -name NativeMethods -namespace Win32
$PSId = (Get-Process | ? { $_.MainWindowTitle -like "*RegionSwitcherGui*"})[0].MainWindowHandle
[Win32.NativeMethods]::ShowWindowAsync($PSId,2)


# Call our Main
BuildGui


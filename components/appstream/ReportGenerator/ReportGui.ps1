Add-Type -AssemblyName System.Windows.Forms
Add-Type -AssemblyName System.Drawing

. C:\ReportGenerator\ReportLibrary.ps1


function OkButtonFunc(){
    $text = $textBox.Text
    
    
    $okButton.Enabled = $false
    $okButton.BackColor = 'red'
    $okButton.text = "Please Wait"
    $cancelButton.Enabled = $false

    if ($FireFoxButton.Checked){
        Write-Host "OUTFILE BEFORE WE CALL: $outfile"
        $outfile = GetFirefoxReports -searchTerm $text
        Write-Host $outfile
        ShowReport -filename $outfile
    } elseif ($ChromeButton.Checked){
        Write-Host "OUTFILE BEFORE WE CALL: $outfile"
        $outfile = GetChromeReports -searchTerm $text
        Write-Host "THIS IS THE OUTFILE WE GET BACK $outfile"
        Write-host $outfile.GetType()
        ShowReport -filename $outfile
    }



    $form.Close()
}
function CancelButtonFunc(){
    $form.Close()
}

$form = New-Object System.Windows.Forms.Form
$form.Text = 'Report Generator'
$form.Size = New-Object System.Drawing.Size(300,210)
$form.StartPosition = 'CenterScreen'

$ChromeButton = New-Object System.Windows.Forms.RadioButton
$ChromeButton.Location = '20,70'
$ChromeButton.size = '350,20'
$ChromeButton.Checked = $true 
$ChromeButton.Text = "Chrome"
$form.Controls.Add($ChromeButton)

$FireFoxButton = New-Object System.Windows.Forms.RadioButton
$FireFoxButton.Location = '20,100'
$FireFoxButton.size = '350,20'
$FireFoxButton.Checked = $false
$FireFoxButton.Text = "Firefox"
$form.Controls.Add($FireFoxButton)

$okButton = New-Object System.Windows.Forms.Button
$okButton.Location = New-Object System.Drawing.Point(75,130)
$okButton.Size = New-Object System.Drawing.Size(75,23)
$okButton.Text = 'OK'
#$okButton.DialogResult = [System.Windows.Forms.DialogResult]::OK
#$form.AcceptButton = $okButton
$form.Controls.Add($okButton)

$cancelButton = New-Object System.Windows.Forms.Button
$cancelButton.Location = New-Object System.Drawing.Point(150,130)
$cancelButton.Size = New-Object System.Drawing.Size(75,23)
$cancelButton.Text = 'Cancel'
#$cancelButton.DialogResult = [System.Windows.Forms.DialogResult]::Cancel
#$form.CancelButton = $cancelButton
$form.Controls.Add($cancelButton)

$okButton.Add_Click({ OkButtonFunc })
$cancelButton.Add_Click({ CancelButtonFunc })

$label = New-Object System.Windows.Forms.Label
$label.Location = New-Object System.Drawing.Point(10,20)
$label.Size = New-Object System.Drawing.Size(280,20)
$label.Text = 'Enter Search Term:'
$form.Controls.Add($label)

$textBox = New-Object System.Windows.Forms.TextBox
$textBox.Location = New-Object System.Drawing.Point(10,40)
$textBox.Size = New-Object System.Drawing.Size(260,20)
$form.Controls.Add($textBox)

$form.Topmost = $true

$form.Add_Shown({$textBox.Select()})
$form.ShowDialog()


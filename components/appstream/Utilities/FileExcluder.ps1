$FolderFilePath = "C:\FindInFiles\Firefox"
$tempFolder = "C:\FindInFiles\Temp\"
$firefoxData = "C:\BrowserData"
$firefoxMaster = "Firefox_Master"

$firefoxbat = "C:\Shortcuts\firefox.bat"
$egressSwitcherBat = "C:\AutoConfig\EgressSwitcher.bat"



. C:\AutoConfig\RegionAndProfileSwitcherLibrary.ps1


function RunSwitcher(){
    ChangeRegionAndProfile  -proxyConnectionString 'us-east-1.r2d2hostedzone:3128'`
         -language 'en-us' -timezone 'Eastern Standard Time' -oldProfile '' -newProfile ''
}

function CopyFolder(){
    Copy-Item -path $FolderFilePath -Destination $firefoxData -Recurse -Force
}


function RestoreSingleFile($file){
    $path = $file.FullName
    $name = $file.Name
    $srcPath = $path.Substring(0,15) + "$firefoxMaster" + $path.Substring(22)
    Copy-Item -Path $srcPath -Destination $path 
}


function RestoreFiles([int] $minIndex, [int] $maxIndex, [Object[]] $allFilePaths){
    for($i = $minIndex; $i -lt $maxIndex; $i++){
        $file = $allFilePaths[$i]
        RestoreSingleFile -file $file
    }
}

function DeleteSingleFile($file){
    $path = $file.FullName
    Remove-Item -Path $path -Force
}


function DeleteFiles([int] $minIndex, [int] $maxIndex, [Object[]] $allFilePaths){
    for($i = $minIndex; $i -lt $maxIndex; $i++){
        $file = $allFilePaths[$i]
        DeleteSingleFile -file $file
    }
}

function StartFirefox(){
    Start-Process $firefoxbat
}

function CheckRegion([int] $minIndex, [int] $maxIndex, [Object[]] $allFilePaths){
    Write-Host "Checking $minIndex to $maxIndex"
    RunSwitcher
    DeleteFiles -minIndex $minIndex -maxIndex $maxIndex -allFilePaths $allFilePaths
    CopyFolder
    StartFirefox
    $userInput = GetUserInput -stringToPrint "Did Firefox Extensions Work"
    if ($userinput -eq 'n'){
        RestoreFiles -minIndex $minIndex -maxIndex $maxIndex -allFilePaths $allFilePaths
    }
    return $userinput
}


function TrimFiles([int] $minIndex, [int] $maxIndex, [Object[]] $allFilePaths){
    Write-Host "Trimming $minIndex to $maxIndex"
    $recurse = $True
    # If there are 2 elements, we dont need to recurse
    if (($maxIndex - $minIndex) -le 1){
        $recurse = $False
    }
    $halfway = ($minIndex+$maxIndex)/2

    #Check the first half
    $userinput = CheckRegion -minIndex $minIndex -maxIndex $halfway -allFilePaths $allFilePaths
    if ($userinput -eq 'n' -and $recurse -eq $True){
        TrimFiles -minIndex $minIndex -maxIndex $halfway -allFilePaths $allFilePaths
    }

    #Check the second half
    $userinput = CheckRegion -minIndex $halfway -maxIndex $maxIndex -allFilePaths $allFilePaths
    if ($userinput -eq 'n' -and $recurse -eq $True){
        TrimFiles -minIndex $halfway -maxIndex $maxIndex -allFilePaths $allFilePaths
    }


}



function GetUserInput($stringToPrint){
    Write-Host $stringToPrint
    do{
        $userinput = Read-Host -Prompt "enter y or n" 
    }while (-not (($userinput -eq 'y') -or($userinput -eq 'n')))
    return $userinput
}


function Old{
    $files = Get-ChildItem $FolderFilePath -Recurse -File
    $files |% {
        $path = $_.FullName
        $name = $_.Name
        Write-Host $path
        
        #Clear FF data
        Start-Process $egressSwitcherBat
        GetUserInput -stringToPrint "Run Egress Switcher"

        #Remove File and Copy remaining into firefox data
        Move-Item -Path $path -Destination $tempFolder -Force
        Copy-Item -path $FolderFilePath -Destination $firefoxData -Recurse -Force

        #Launch firefox, ask if extentions work
        Start-Process $firefoxbat
        $userinput = GetUserInput -stringToPrint "Did the extensions work?"

        #if extensions didnt work, then put the file back
        if($userinput -eq 'n'){
            Move-Item -Path ($tempFolder+$name) -Destination $path
        }
        #Move on to next file
    }
}


$files = Get-ChildItem $FolderFilePath -Recurse -File
$minIndex = 0
$maxIndex = $files.Length

TrimFiles -minIndex $minIndex -maxIndex $maxIndex -allFilePaths $files

#Write-Host $files.GetType()




$chromePath = "C:\Program Files\Google\Chrome\Application\chrome.exe"
$firefoxPath = "C:\Program Files\Mozilla Firefox\firefox.exe"
$maxTimeSeconds = 30
$retryInterval = 1

$chromeRegPath = "HKLM:\SOFTWARE\Policies\Google\Chrome\"
$proxySettings = (Get-Item $chromeRegPath).GetValue("ProxySettings")
$proxyJson = ConvertFrom-Json $proxySettings
$chromeProxy = $proxyJson.ProxyServer

$outDir = "C:\Users\${env:USERNAME}\My Files\Temporary Files\"

$urls = @(
    'https://google.com/search?q=',
    'https://www.facebook.com/public?query=',
    'https://gramuser.com/search/',
    'https://www.youtube.com/results?search_query='
)


$twitterUrl = 'https://mobile.twitter.com/search/users?q='

function GetTwitterReport($searchTerm){
    $searchURL = $twitterUrl + $searchTerm
    $twitterFile = $outDir + "twitterTemp.html"
    $twitterFileName = "file:///"+$twitterFile
    Invoke-WebRequest -Uri $twitterUri -Proxy "http://${chromeProxy}:3128" -OutFile $twitterFileName
    return $twitterFile
}

#$urls = @('https://google.com/search?q=')


function GetFirefoxReports($searchTerm){
    $dateStr = GetFormatedDate
    $searchUrls = GetSearchUrls -searchTerm $searchTerm

    $twitterFile = GetTwitterReport -searchTerm $searchTerm
    $twitterUrl = "file:///"+$twitterFile
    $searchUrls +=  $twitterUrl

    $count = 1

    $filenames = @()
    $outfileName = $outDir + $searchTerm + "_" + $dateStr + ".png"
    Write-Host $outfileName.GetType()
    $searchUrls | % {
        Write-Host $count
        $filename = $outDir + $searchTerm + "_${count}_" + $dateStr + ".png"
        Write-Host $_
        FireFoxSingleURL -url $_ -outfilePath $filename
        $count = $count+1
        
        $filenames += $filename
    }

    CombineImages -filenames $filenames -outFileName $outfileName

    $filenames += $twitterFile

    CleanUp -filenames $filenames
    return $outfileName
}

function GetChromeReports($searchTerm){
    $dateStr = GetFormatedDate
    $searchUrls = GetSearchUrls -searchTerm $searchTerm

    $twitterFile = GetTwitterReport -searchTerm $searchTerm
    $twitterUrl = "file:///"+$twitterFile
    $searchUrls +=  $twitterUrl

    $count = 1

    $filenames = @()
    $outfileName = $outDir + $searchTerm + "_" + $dateStr + ".pdf"

    $searchUrls | % {
        Write-Host $count
        $filename = $outDir + $searchTerm + "_${count}_" + $dateStr + ".pdf"
        Write-Host $_
        ChromeSingleURL -url $_ -outfilePath $filename
        $count = $count+1
        $filenames += $filename
    }

    CombinePDFs -filenames $filenames -outFileName $outfileName

    $filenames += $twitterFile

    CleanUp -filenames $filenames
    Write-Host $outfileName.GetType()
    Write-Host "THIS IS THE OUTFILE $outfileName"
    [string]$toret = "${outfileName}"
    return $toret
}


function GetFormatedDate(){
    return Get-Date -Format "ddMMMyyy_HHmm" 
}

function GetSearchUrls($searchTerm){
    $output = $urls | % {$_ + $searchTerm}
    return $output
}

function ChromeSingleURL($url, $outfilePath){
    #& $chromePath --proxy-server=$chromeProxy --headless --disable-gpu --run-all-compositor-stages-before-draw --print-to-pdf="$outfilePath" $url --virtual-time-budget=10000
    & $chromePath --proxy-server=$chromeProxy --headless $url --disable-gpu --run-all-compositor-stages-before-draw --print-to-pdf="$outfilePath" --virtual-time-budget=1000000
    ValidateFileExists -filePath $outfilePath
}

function FireFoxSingleURL($url, $outfilePath){
    #Write-Host $url +" " + $outfilePath
    & $firefoxPath --screenshot "$outfilePath" "$url"
    ValidateFileExists -filePath $outfilePath
}

function ValidateFileExists($filePath){
     while( -not (Test-Path $filePath)){
        #Write-Host "file doesnt exist"
        Start-Sleep -Seconds $retryInterval
     }
     #Write-Host "File exists"
}


function CombinePDFs($filenames, $outFileName){
    #Start-Sleep -Seconds 10
    $output = $filenames | Merge-Pdf -OutputPath $outFileName
    #Start-Sleep -Seconds 10
    Write-Host "IS THIS THE CULPRIT?"
    Write-host $output
}


function CombineImages($filenames, $outFileName){
    $images = $filenames | %{
        [System.Drawing.Bitmap]::FromFile($_)
    }

    $totalHeight = (($images.Height) | Measure-Object -Sum).Sum

    $width = $images[0].width


    $finalImage = [System.Drawing.Bitmap]::new($width, $totalHeight)
    $canvas = [System.drawing.graphics]::FromImage($finalImage)
    $canvas.Clear([System.Drawing.Color]::White)


    $currentYLoc = 0
    $images | %{
        $canvas.DrawImage($_, 0, $currentYLoc)
        $currentYLoc += $_.Height
    }

    $finalImage.Save($outFileName, [System.Drawing.Imaging.ImageFormat]::Png)
    $images.Dispose()
  
}

function CleanUp($filenames){
    $filenames | % { Remove-Item -Path $_}
}

function ShowReport($filename){

    Write-Host "$chromePath $filename"
    & $chromePath $filename
}


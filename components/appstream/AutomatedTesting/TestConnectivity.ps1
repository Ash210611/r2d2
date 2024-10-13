$file = "C:\AutoConfig\ProxyConfig.csv"
$outFile = "C:\AutoConfig\ProxyTestResults.csv"

function TestProxy($proxy){
    $proxyUrl = "http://$proxy"
    $suceed = $true
    try{
        $result = Invoke-WebRequest -Uri "https://google.com" -Proxy $proxyUrl
    } catch {
        Write-Host $_
        $suceed = $false
    }
    Write-Host $suceed
    return $suceed
}

function Main(){
    $proxyFile = Get-Content $file
    $allProxyGood = $true
    $proxyFile | %{
        $line = $_
        $splitline = $line.Split(',')
        if ($splitline.Length -gt 1){
            $proxyUrl = $splitline[1]
            $result = TestProxy -proxy $proxyUrl
            if ($result){
                Write-Host "$($splitline[0]): Good!"
                "$($splitline[0]),connected" >> $outFile

            }else{
                $allProxyGood = $false
                Write-Host "$($splitline[0]): ERROR"
                "$($splitline[0]),disconnected" >> $outFile
            }
        }
    }
}

Main

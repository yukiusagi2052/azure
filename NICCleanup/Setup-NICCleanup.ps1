
$TargetDir = 'C:\Packages\NICCleanup'

New-Item -Path $TargetDir -Type Directory
Set-Location $TargetDir

$url = 'http://go.microsoft.com/?linkid=9829438'
$uri = New-Object System.Uri($url)
$file = 'MicrosoftEasyFix25010.mini.diagcab'
$cli = New-Object System.Net.WebClient
$cli.DownloadFile($uri, (Join-Path $TargetDir $file))

Start-Process -FilePath expand.exe -ArgumentList "MicrosoftEasyFix25010.mini.diagcab . -f:devcon_V8_AMD64.exe" -Wait

$url = 'https://gallery.technet.microsoft.com/scriptcenter/Device-Management-7fad2388/file/65051/2/DeviceManagement.zip'
$uri = New-Object System.Uri($url)
$file = 'DeviceManagement.zip'
$cli = New-Object System.Net.WebClient
$cli.DownloadFile($uri, (Join-Path $TargetDir $file))

Configuration DscUnzip
{
    Node localhost
    {
        Archive UnZip
        {
            Path = (Join-Path $TargetDir $file)
            Destination = $TargetDir
            Ensure = "Present"
        }
    }
}
DscUnzip -OutputPath .
Start-DscConfiguration .\DscUnzip -Wait -Verbose


$url = 'https://raw.githubusercontent.com/yukiusagi2052/azure/master/NICCleanup/Setup-NICCleanup.ps1'
$uri = New-Object System.Uri($url)
$file = Split-Path $uri.AbsolutePath -Leaf
$cli = New-Object System.Net.WebClient
$cli.DownloadFile($uri, (Join-Path $TargetDir $file))


$url = 'https://raw.githubusercontent.com/yukiusagi2052/azure/master/NICCleanup/HiddenNICRemove.ps1'
$uri = New-Object System.Uri($url)
$file = Split-Path $uri.AbsolutePath -Leaf
$cli = New-Object System.Net.WebClient
$cli.DownloadFile($uri, (Join-Path $TargetDir $file))

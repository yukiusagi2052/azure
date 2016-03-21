
$TargetDir = 'C:\Packages\NICCleanup'

New-Item -Path $TargetDir -Type Directory
Set-Location $TargetDir

## Step1 devcon.exe
$url = 'http://go.microsoft.com/?linkid=9829438'
$uri = New-Object System.Uri($url)
$file = 'MicrosoftEasyFix25010.mini.diagcab'
$cli = New-Object System.Net.WebClient
$cli.DownloadFile($uri, (Join-Path $TargetDir $file))

Start-Process -FilePath expand.exe -ArgumentList "MicrosoftEasyFix25010.mini.diagcab . -f:devcon_V8_AMD64.exe" -Wait
Rename-Item -Path .\devcon_V8_AMD64.exe devcon.exe
Remove-Item -Path .\MicrosoftEasyFix25010.mini.diagcab

## Step2 Device Management Powershell
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
Remove-Item -Recurse -Path .\DscUnzip
Remove-Item -Path .\DeviceManagement.zip
Rename-Item .\Release DeviceManagement

## Step3 HiddenNICRemove.ps1
$url = 'https://raw.githubusercontent.com/yukiusagi2052/azure/master/NICCleanup/HiddenNICRemove.ps1'
$uri = New-Object System.Uri($url)
$file = Split-Path $uri.AbsolutePath -Leaf
$cli = New-Object System.Net.WebClient
$cli.DownloadFile($uri, (Join-Path $TargetDir $file))

## Step4 NICCleanup.bat
$url = 'https://raw.githubusercontent.com/yukiusagi2052/azure/master/NICCleanup/NICCleanup.bat'
$uri = New-Object System.Uri($url)
$file = Split-Path $uri.AbsolutePath -Leaf
$cli = New-Object System.Net.WebClient
$cli.DownloadFile($uri, (Join-Path $TargetDir $file))


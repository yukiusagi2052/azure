#
# PSScript.ps1
#

New-Item -Path 'C:\Powershell' -ItemType directory > $null

Write-Output "Hello Powershell Script" | Set-Content 'C:\Powershell\Hello.txt'

Write-Output $PWD | Set-Content 'C:\Powershell\PWD.txt'

Write-Output $env:USERNAME | Set-Content 'C:\Powershell\UserName.txt'

Write-Output $env:USERDOMAIN | Set-Content 'C:\Powershell\UserDomain.txt'
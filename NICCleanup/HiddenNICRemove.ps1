Import-Module .\Release\DeviceManagement.psd1
$hiddenHypVNics = Get-Device -ControlOptions DIGCF_ALLCLASSES | Sort-Object -Property Name | Where-Object { ($_.IsPresent -eq $false) -and ($_.Name -like "Microsoft Hyper-V Network Adapter*") }
$hiddenHypVNics | ForEach-Object {
  .\devcon.exe remove "@$($_.InstanceId.Replace("`0", ''))"
}
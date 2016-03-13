<#
    .SYNOPSIS
        This Azure Automation runbook automates the scheduled resizing of virtual machines in an Azure subscription. 

    .DESCRIPTION
        The runbook implements a solution for scheduled size management of Azure virtual machines in combination

        This is a PowerShell runbook, as opposed to a PowerShell runbook.

        This runbook requires the "Azure" and "AzureRM.Resources" modules which are present by default in Azure Automation accounts.
        For detailed documentation and instructions, see: 
        
        https://automys.com/library/asset/scheduled-virtual-machine-shutdown-startup-microsoft-azure

    .PARAMETER AzureCredentialAssetName
        The name of the PowerShell credential asset in the Automation account that contains username and password
        for the account used to connect to target Azure subscription. This user must be configured as co-administrator and owner
        of the subscription for best functionality. 

        By default, the runbook will use the credential with name "DefaultAzureCredential"

        For for details on credential configuration, see:
        http://azure.microsoft.com/blog/2014/08/27/azure-automation-authenticating-to-azure-using-azure-active-directory/
    
    .PARAMETER AzureSubscriptionIdAssetName
        The ID of Azure subscription in which the resources will be created. By default, the runbook will use 
        the value defined in the Variable setting named "DefaultAzureSubscriptionId"
    
    .PARAMETER ResourceGroupName
        The name of resouce group included a your target virtual machin.    

    .PARAMETER VmName
        The name of a your target virtual machin.    
    
    .PARAMETER VmSize
        your choice of virtual machine size.
        example) Basic_A1, Standard_A1, Standard_D2, Standard_DS3    
    
    .INPUTS
        None.

    .OUTPUTS
        Human-readable informational and error messages produced during the job. Not intended to be consumed by another runbook.

    .NOTES
        AUTHOR: @yukiusagi2052 
        LASTEDIT: March 14, 2016
#>

param (
    [Parameter(Mandatory=$false)] 
    [String]  $AzureCredentialAssetName = 'DefaultAzureCredential',
        
    [Parameter(Mandatory=$false)]
    [String] $AzureSubscriptionIdAssetName = 'DefaultAzureSubscriptionId',

    [Parameter(Mandatory=$true)]
    [String] $ResourceGroupName,

    [Parameter(Mandatory=$true)] 
    [String] $VmName,

    [Parameter(Mandatory=$true)] 
    [String] $VmSize
)

try
{
    # Connect to Azure and select the subscription to work against
    $Cred = Get-AutomationPSCredential -Name $AzureCredentialAssetName -ErrorAction Stop

    $null = Add-AzureRmAccount -Credential $Cred -ErrorAction Stop -ErrorVariable err
    if($err) {
        throw $err
    }

    $SubId = Get-AutomationVariable -Name $AzureSubscriptionIdAssetName -ErrorAction Stop
    $null = Select-AzureRmSubscription -SubscriptionId $SubId

	
    $VM = Get-AzureRmVM -ResourceGroupName $ResourceGroupName -Name $VmName

    if($VM -eq $null)
	{
		Write-Output ("a specific VM is not found")
	} else
    {
		Write-Output ("VM: " + $VM.Name)

		$VmStatus = Get-AzureRmVM -ResourceGroupName $ResourceGroupName -Name $VmName -Status
	    if( $VmStatus.Statuses.Item(1).code -eq "PowerState/running")
	    {
	        $VmRunning = $true
	    } else {
	        $VmRunning = $false		
		}
		Write-Output ("VMRunning: " + $VmRunning) 

        if($VmRunning)
        {    
            # Stop the VM
            $StopRtn = $VM | Stop-AzureRmVM -StayProvisioned -Force -ErrorAction Continue

            if ($StopRtn.IsSuccessStatusCode)
            {
                # The VM stopped, so send notice
                Write-Output ($VM.Name + " has been stopped")
            }
            else
            {
                # The VM failed to stop, so send notice
                Write-Output ($VM.Name + " failed to stop")
                Write-Error ($VM.Name + " failed to stop. Error was:") -ErrorAction Continue
                Write-Error (ConvertTo-Json $StopRtn.Error) -ErrorAction Continue
            }
        }

        # resize the VM
        $VM.HardwareProfile.VmSize = $VmSize
        $UpdateRtn = Update-AzureRmVM -ResourceGroupName $ResourceGroupName -VM $VM

        if ($UpdateRtn.IsSuccessStatusCode)
        {
            # The VM resized, so send notice
            Write-Output ($VM.Name + " has been resized")
        }
        else
        {
            # The VM failed to resize, so send notice
            Write-Output ($VM.Name + " failed to resize")
            Write-Error ($VM.Name + " failed to resize. Error was:") -ErrorAction Continue
            Write-Error (ConvertTo-Json $UpdateRtn.Error) -ErrorAction Continue
        }

        if($VmRunning)
        {    
            # Start the VM
            $StartRtn = $VM | Start-AzureRmVM -ErrorAction Continue
			
            if ($StartRtn.IsSuccessStatusCode)
            {
                # The VM started, so send notice
                Write-Output ($VM.Name + " has been started")
            }
            else
            {
                # The VM failed to start, so send notice
                Write-Output ($VM.Name + " failed to start")
                Write-Error ($VM.Name + " failed to start. Error was:") -ErrorAction Continue
                Write-Error (ConvertTo-Json $StartRtn.Error) -ErrorAction Continue
            }
        }
    }
}
catch
{
    $errorMessage = $_.Exception.Message
    throw "Unexpected exception: $errorMessage"
}
finally
{
    Write-Output "Runbook finished"
}
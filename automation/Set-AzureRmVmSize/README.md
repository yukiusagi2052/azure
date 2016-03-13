Azure Automation Runbook.
------------------------

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

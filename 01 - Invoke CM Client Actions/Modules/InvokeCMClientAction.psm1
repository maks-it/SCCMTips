<#
.SYNOPSIS
Samle script to dimostrate Configuration Manager Clien Actions invoke thought WMI call

Author: Maksym Sadovnychyy (Maks-IT)
Web Site: https://www.maks-it.com
Project Site: https://github.com/maks-it/SCCMTips

#>

function Invoke-CMClientAction {
    param(
        [string]$HostName,
        [psobject []]$Actions
    )

    try {
        Write-Log -Text "Trying to connect $HostName..."
    
        if(Test-Connection -ComputerName $HostName -Quiet) {
            Write-Log -Text "Connecting to $HostName..."
    
            foreach($action in $Actions) {
                Write-Log -Text "Invoking action $action..."
                Invoke-WmiMethod -ComputerName $HostName -Namespace "root\ccm" -Class "sms_client" -Name "TriggerSchedule" $action
                Write-Log -Text "OK: Action invoked."
            }
        }
        else {
            Write-Log -Text "WARN: Host $HostName is offline"
        }
    }
    catch {
        Write-Log -Text ("ERR: " + $_.Exception.Message)
    }
}
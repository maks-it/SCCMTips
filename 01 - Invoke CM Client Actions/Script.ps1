<#
.SYNOPSIS
Samle script to dimostrate Configuration Manager Clien Actions invoke thought WMI call

Author: Maksym Sadovnychyy (Maks-IT)
Web Site: https://www.maks-it.com
Project Site: https://github.com/maks-it/SCCMTips

#>

$scriptPath = $PSScriptRoot


try {
    import-Module -Name "$scriptPath\Modules\WriteLog.psm1"
    #Import-Module (Join-Path $(Split-Path $env:SMS_ADMIN_UI_PATH) ConfigurationManager.psd1)
    import-Module -Name "$scriptPath\Modules\InvokeCMClientAction.psm1"
}
catch {
    Write-Host ($(Get-Date -Format "dd/MM/yyyy HH:mm") + " - ERR: " + $_.Exception.Message)
    exit 1
}

try {
    $cmActions = New-Object System.Collections.ArrayList
    $cmActions.Add("{00000000-0000-0000-0000-000000000002}") | Out-Null

    Invoke-CMClientAction -HostName "Your Host Name" -Actions $cmActions

    exit 0
}
catch {
    Write-Host ($(Get-Date -Format "dd/MM/yyyy HH:mm") + " - ERR: " + $_.Exception.Message)
    exit 1
}
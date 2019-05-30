<#
.SYNOPSIS
Samle script to dimostrate Configuration Manager Clien Actions invoke thought WMI call

Author: Maksym Sadovnychyy (Maks-IT)
Web Site: https://www.maks-it.com
GitHub: https://github.com/maks-it
#>

$scriptPath = $PSScriptRoot


try {
    import-Module -Name "$scriptPath\Modules\WriteLog.psm1"
    #Import-Module (Join-Path $(Split-Path $env:SMS_ADMIN_UI_PATH) ConfigurationManager.psd1)
    import-Module -Name "$scriptPath\Modules\SetCMCollectionRefreshType.psm1"
}
catch {
    Write-Host ($(Get-Date -Format "dd/MM/yyyy HH:mm") + " - ERR: " + $_.Exception.Message)
    exit 1
}

try {
    # See \Modules\SetCMCollectionRefreshType.psm1 for more details on usage
    Set-CMCollectionRefreshType -CollectionName "Your Collection Name" -Server "Your CM Server" -RefreshType "Your Refresh Type 1 2 4 6" -DaySpan "Your Day Span"

    exit 0
}
catch {
    Write-Host ($(Get-Date -Format "dd/MM/yyyy HH:mm") + " - ERR: " + $_.Exception.Message)
    exit 1
}
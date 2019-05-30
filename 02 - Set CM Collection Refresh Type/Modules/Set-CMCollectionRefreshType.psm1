<#
.SYNOPSIS
Author: Maksym Sadovnychyy (Maks-IT)
Web Site: https://www.maks-it.com
GitHub: https://github.com/maks-it

.DESCRIPTION
Refresh Type 1: Manual, No Incremental
Refresh Type 2: Schedule, No Incremental
Refresh Type 4: Manual, Incremental
Refresh Type 6: Schedule Incremental
#>

function Set-CMCollectionRefreshType {
    param (
        [String]$CollectionID,
        [String]$CollectionName,
        [String]$Server,
        [int]$RefreshType,
        [int]$DaySpan
    )


    try {
        if(!$Server) {
            $Server = '.'
        }

        $siteCode = @(Get-WmiObject -Namespace "root\sms" -Class "SMS_ProviderLocation" -ComputerName $Server)[0].SiteCode

        Get-WmiObject -Namespace "root\sms\site_$siteCode" -Class "sms_collection" -ComputerName $Server  -Filter "CollectionID = '$CollectionID' or Name = '$CollectionName'" | ForEach-Object {
            $collection = [wmi] $_.__Path 

            $collection.RefreshType = $RefreshType

            #region Schedule a full update on this collection
            if($RefreshType -eq 2 -or $RefreshType -eq 6) {
                $IntervalClass = Get-WmiObject -Namespace "root\sms\site_$SiteCode" -Class "SMS_ST_RecurInterval" -ComputerName $Server -List

                $interval = $intervalClass.CreateInstance()
                $interval.dayspan = $DaySpan
                $interval.starttime = [DateTime]::Now.ToString("yyyyMMddHHmmss.000000+***")
        
                $collection.RefreshSchedule = $interval
            }
            #endregion

            $collection.Put() | Out-Null

            Write-Log -Text "OK: Refresh Type Changed."
        }
    }
    catch {
        Write-Log -Text ("ERR: " + $_.Exception.Message)
    }
}
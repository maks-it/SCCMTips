<#
.SYNOPSIS
Author: Maksym Sadovnychyy (Maks-IT)
Web Site: https://www.maks-it.com
GitHub: https://github.com/maks-it
#>

function Write-Log {
    param(
        [string]$Text = ""
    )

    $logString = $(Get-Date -Format "dd/MM/yyyy HH:mm") + " - $Text"

	try {
		if ($Text -like "err:*" ) {
			Write-Host $logString -ForegroundColor Red
		}
		elseif ($Text -like "warn:*" ) {
			Write-Host $logString -ForegroundColor Yellow
		}
		elseif ($Text -like "ok:*" ) {
			Write-Host $logString -ForegroundColor Green
        }
        elseif ($Text -like "debug:*" ) {
			Write-Host $logString -ForegroundColor DarkMagenta
        }
        elseif ($Text -like "note:*" ) {
			Write-Host $logString -ForegroundColor Cyan
        }
        elseif ($Text -like "code:*" ) {
			Write-Host $logString -ForegroundColor Blue
		}
		else {
			Write-Host $logString
        }
	}
	catch {
		Write-Host ($(Get-Date -Format "dd/MM/yyyy HH:mm") + " - ERR: " + $_.Exception.Message)
	}
}
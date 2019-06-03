<#
.SYNOPSIS
Samle script to dimostrate Configuration Manager Clien Actions invoke thought WMI call

Author: Maksym Sadovnychyy (Maks-IT)
Web Site: https://www.maks-it.com
GitHub: https://github.com/maks-it
#>

#region functions
function Get-RegValues {
	param (
		[string]$RegPath
	)

	$result = New-Object System.Collections.ArrayList

	$regKey = Get-Item -Path $RegPath -ErrorAction SilentlyContinue
	foreach ($keyValueName in $regKey.GetValueNames()) {
		$result.Add([pscustomobject]@{'Path'=$regKey.Name;'Name'=$keyValueName;'Data'=$regKey.GetValue($keyValueName);'Type'=$regKey.GetValueKind($keyValueName)}) | Out-Null
	}

	return $result
}

function New-UserObject {
	param(
		[string]$UserSID,
		[string]$UserName
	)

	$obj = New-Object -TypeName psobject
	Add-Member -InputObject $obj -Name "UserSID" -MemberType NoteProperty -Value $UserSID
	Add-Member -InputObject $obj -Name "UserName" -MemberType NoteProperty -Value $UserName

	return $obj
}

function Get-UsersFromHiveList {
	$result = New-Object System.Collections.ArrayList

	foreach($regValue in Get-RegValues -RegPath "HKLM:\SYSTEM\CurrentControlSet\Control\hivelist") {
		if($regValue.Name -like "*USER*" -and $regValue.Name -notlike "*Classes*" -and $regValue.Data -like "*Users*") {
			$userSID = $regValue.Name.Split('\')[3]
			$userName = $regValue.Data.Split('\')[4]
			
			$result.Add((New-UserObject -UserSID $userSID -UserName $userName)) | Out-Null
		}
	}

	return $result
}

function New-WinRegPath {
	param (
		[string]$Scope,
		[String]$RegPath
	)

	$obj = New-Object -TypeName psobject
	Add-Member -InputObject $obj -Name "Scope" -MemberType NoteProperty -Value $Scope
	Add-Member -InputObject $obj -Name "RegPath" -MemberType NoteProperty -Value $RegPath

	return $obj
}

function Get-UninstallKeys {
	$result = New-Object System.Collections.ArrayList

	$result.Add((New-WinRegPath -Scope "Machine" -RegPath "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall")) | Out-Null
	if ($env:PROCESSOR_ARCHITECTURE -eq 'AMD64') {
		$result.Add((New-WinRegPath -Scope "Machine" -RegPath "HKLM:\SOFTWARE\Wow6432Node\Microsoft\Windows\CurrentVersion\Uninstall")) | Out-Null
	}

	foreach($regKey in Get-UsersFromHiveList) {
		$regPath = "registry::HKEY_USERS\$($regKey.UserSID)\Software\Microsoft\Windows\CurrentVersion\Uninstall"
		if (Get-Item -Path $regPath -ErrorAction SilentlyContinue) {
			$result.Add((New-WinRegPath -Scope $regKey.UserName -RegPath $regPath )) | Out-Null
		}
	}

	return $result
}

function New-InstalledItem {
	param (
		[string]$Scope,
		[psobject []]$RegValues
	)

	$obj = New-Object -TypeName psobject
	Add-Member -InputObject $obj -Name "Scope" -MemberType NoteProperty -Value $Scope
	Add-Member -InputObject $obj -Name "RegValues" -MemberType NoteProperty -Value $RegValues

	return $obj
}

function Get-Programs {
	$installedItems = New-Object System.Collections.ArrayList

	foreach ($uninstallPath in Get-UninstallKeys) {
		foreach ($appKeyName in $(Get-Item -Path ($uninstallPath.RegPath) -ErrorAction SilentlyContinue).GetSubKeyNames()) {
			$installedItems.Add((New-InstalledItem -Scope $uninstallPath.Scope -RegValues (Get-RegValues -RegPath "$($uninstallPath.RegPath)\$appKeyName"))) | Out-Null
		}
	}

	$columnNames = New-Object System.Collections.ArrayList
	foreach($installedItem in $installedItems) {
		foreach($regValue in $installedItem.RegValues) {
			if ($regValue.Name -ne "") {
				$columnNames.Add($regValue.Name) | Out-Null
			}
			else {
				$columnNames.Add("WindowsKB") | Out-Null
			}
		}
	}

	$columnNames = $columnNames | Sort-Object | Get-Unique

	$result = New-Object System.Collections.ArrayList
	foreach($installedItem in $installedItems) {

		$itemObj = New-Object -TypeName pscustomobject
		Add-Member -InputObject $itemObj -Name "Scope" -MemberType NoteProperty -Value $installedItem.Scope

		foreach($col in $columnNames) {
			$found = $false
			foreach($regValue in $installedItem.RegValues) {
				if($col -eq $regValue.Name) {
					Add-Member -InputObject $itemObj -Name $col -MemberType NoteProperty -Value ([string]$regValue.Data) -Force
					$found = $true
				}

				if($col -eq "WindowsKB" -and $regValue.Name -eq "") {
					Add-Member -InputObject $itemObj -Name $col -MemberType NoteProperty -Value ([string]$regValue.Data) -Force
					$found = $true
				}
			}

			if(-not $found) {
				Add-Member -InputObject $itemObj -Name $col -MemberType NoteProperty -Value "" -Force
			}
		}

		$result.Add($itemObj) | Out-Null
	}
	
	# Uncomment to see all software installed
	# $result | Out-GridView -Wait

	return $result
}

function Find-Software {
    param(
        [psobject[]]$DetectionRules
    )

	$programs = Get-Programs

    $response = New-Object System.Collections.ArrayList
    foreach($detectionRule in $DetectionRules) {

		$found = $programs | Where-Object { $_.DisplayName -like $detectionRule.DispalyName -and $_.DisplayVersion -like $detectionRule.DisplayVersion -and ($_.Scope -eq "Machine" -or $_.Scope -eq $env:USERNAME) }

		if($($found | Measure-Object).Count -gt 0){
			$response.Add($true) | Out-Null
		}
		else {
			$response.Add($false) | Out-Null
		}
    }

    return $response
}

function New-SWObject {
	param(
		[string]$DisplaName,
		[string]$DisplayVersion
	)

	$obj = New-Object -TypeName psobject
	Add-Member -InputObject $obj -Name "DispalyName" -MemberType NoteProperty -Value $DisplaName
	Add-Member -InputObject $obj -Name "DisplayVersion" -MemberType NoteProperty -Value $DisplayVersion

	return $obj
}

#endregion functions

$detectionRules = New-Object System.Collections.ArrayList

#Detection rule example
$detectionRules.Add((New-SWObject -DisplaName "*Google*" -DisplayVersion "*")) | Out-Null

$swDetected = @(Find-Software -DetectionRules $detectionRules)
if(-not $swDetected -contains $false) {
	Write-Host "Installed"
}
else {
	
}
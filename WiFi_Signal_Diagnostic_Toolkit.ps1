#requires -Version 5.1
<#
.SYNOPSIS
    WiFi Signal Diagnostic Toolkit.
.DESCRIPTION
    Read-only wireless signal and adapter context reporter. It does not export wireless passwords.
#>
[CmdletBinding()]
param([string]$OutputPath)

$RunStamp = Get-Date -Format 'yyyyMMdd_HHmmss'
if ([string]::IsNullOrWhiteSpace($OutputPath)) { $OutputPath = Join-Path ([Environment]::GetFolderPath('Desktop')) 'WiFi_Diagnostic_Reports' }
New-Item -Path $OutputPath -ItemType Directory -Force | Out-Null
$interfaceText = (& netsh.exe wlan show interfaces 2>&1) -join [Environment]::NewLine
$driversText = (& netsh.exe wlan show drivers 2>&1) -join [Environment]::NewLine
$interfacePath = Join-Path $OutputPath "wifi_interfaces_$RunStamp.txt"
$driversPath = Join-Path $OutputPath "wifi_drivers_$RunStamp.txt"
$interfaceText | Set-Content $interfacePath -Encoding UTF8
$driversText | Set-Content $driversPath -Encoding UTF8
$adapters = Get-NetAdapter -ErrorAction SilentlyContinue | Where-Object {$_.InterfaceDescription -match 'Wireless|Wi-Fi|WiFi|802.11'} | Select-Object Name,Status,LinkSpeed,MacAddress,InterfaceDescription
$adapters | Export-Csv (Join-Path $OutputPath "wifi_adapters_$RunStamp.csv") -NoTypeInformation -Encoding UTF8
$summary = [PSCustomObject]@{Computer=$env:COMPUTERNAME;Generated=Get-Date;InterfaceReport=$interfacePath;DriverReport=$driversPath;WirelessAdapterCount=@($adapters).Count}
$html = "<h1>WiFi Signal Diagnostic - $env:COMPUTERNAME</h1><p>Generated $(Get-Date)</p><h2>Wireless Adapters</h2>$($adapters | ConvertTo-Html -Fragment)<h2>Interface Text</h2><pre>$($interfaceText -replace '<','&lt;' -replace '>','&gt;')</pre>"
$html | ConvertTo-Html -Title 'WiFi Signal Diagnostic' | Set-Content (Join-Path $OutputPath "wifi_signal_report_$RunStamp.html") -Encoding UTF8
$summary | Format-List
Write-Host "Reports saved to: $OutputPath" -ForegroundColor Green
Start-Process explorer.exe -ArgumentList "`"$OutputPath`"" -ErrorAction SilentlyContinue

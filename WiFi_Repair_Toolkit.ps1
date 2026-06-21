[CmdletBinding(SupportsShouldProcess=$true,ConfirmImpact='High')]
param(
 [string]$AdapterName,
 [switch]$RestartAdapter,
 [switch]$RenewDhcp,
 [switch]$FlushDns,
 [switch]$RestartWlanService,
 [string]$ForgetProfile,
 [switch]$DryRun,[switch]$Yes,
 [string]$OutputPath=(Join-Path $env:ProgramData 'WiFiRepairReports')
)
$ErrorActionPreference='Stop';$script:Failures=0;$script:Actions=0
$run=Join-Path $OutputPath (Get-Date -Format yyyyMMdd_HHmmss);New-Item -ItemType Directory $run -Force|Out-Null
$log=Join-Path $run 'repair.log';$before=Join-Path $run 'before.txt';$after=Join-Path $run 'after.txt'
function Log($m){"$(Get-Date -Format 'yyyy-MM-dd HH:mm:ss') $m"|Tee-Object -FilePath $log -Append}
function Admin{$p=[Security.Principal.WindowsPrincipal]::new([Security.Principal.WindowsIdentity]::GetCurrent());$p.IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)}
function State($path){@("Collected: $(Get-Date -Format o)",(& netsh wlan show interfaces|Out-String),(& ipconfig /all|Out-String),(Get-NetAdapter -Physical|Format-Table -Auto|Out-String))|Set-Content $path -Encoding UTF8}
function Act($d,[scriptblock]$a){$script:Actions++;Log $d;if($DryRun){Log "DRY-RUN: $d";return};try{&$a;Log "SUCCESS: $d"}catch{$script:Failures++;Log "FAILED: $d - $($_.Exception.Message)"}}
State $before
if(-not($RestartAdapter -or $RenewDhcp -or $FlushDns -or $RestartWlanService -or $ForgetProfile)){Write-Error 'Choose at least one repair action.';exit 2}
if(($RestartAdapter -or $RenewDhcp -or $RestartWlanService) -and -not $DryRun -and -not(Admin)){Write-Error 'Run from elevated PowerShell.';exit 4}
if(($RestartAdapter -or $RenewDhcp) -and -not $AdapterName){$AdapterName=(Get-NetAdapter -Physical|Where-Object {$_.InterfaceDescription -match 'Wireless|Wi-Fi|802.11'}|Select-Object -First 1 -ExpandProperty Name)}
if(($RestartAdapter -or $RenewDhcp) -and -not $AdapterName){Write-Error 'Wireless adapter not found. Supply -AdapterName.';exit 2}
if(-not $Yes -and -not $DryRun){if((Read-Host 'Apply selected Wi-Fi repairs? Connectivity may drop. Type YES') -ne 'YES'){Log 'Cancelled.';exit 10}}
if($RestartWlanService){Act 'Restarting WLAN AutoConfig service' {Restart-Service WlanSvc -Force}}
if($RestartAdapter){Act "Restarting adapter $AdapterName" {Restart-NetAdapter -Name $AdapterName -Confirm:$false}}
if($RenewDhcp){Act "Renewing DHCP on $AdapterName" {& ipconfig.exe /release "$AdapterName"|Out-Null;& ipconfig.exe /renew "$AdapterName"|Out-Null}}
if($FlushDns){Act 'Flushing DNS resolver cache' {Clear-DnsClientCache}}
if($ForgetProfile){Act "Removing saved Wi-Fi profile $ForgetProfile" {& netsh wlan delete profile name="$ForgetProfile"|Out-Null;if($LASTEXITCODE){throw "netsh exited $LASTEXITCODE"}}}
Start-Sleep 3;State $after
if($script:Failures){Log "Completed with $script:Failures failure(s).";exit 20};Log "Repair completed. Actions: $script:Actions";exit 0

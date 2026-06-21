# WiFi Signal Diagnostic Toolkit

A PowerShell toolkit for Wi-Fi signal diagnostics and selected guarded wireless repairs.

## Diagnostic script

```powershell
powershell.exe -ExecutionPolicy Bypass -File .\WiFi_Signal_Diagnostic_Toolkit.ps1
```

## Repair script

```powershell
powershell.exe -ExecutionPolicy Bypass -File .\WiFi_Repair_Toolkit.ps1 -RestartAdapter -DryRun
```

Examples:

```powershell
.\WiFi_Repair_Toolkit.ps1 -RestartWlanService
.\WiFi_Repair_Toolkit.ps1 -AdapterName Wi-Fi -RestartAdapter
.\WiFi_Repair_Toolkit.ps1 -AdapterName Wi-Fi -RenewDhcp
.\WiFi_Repair_Toolkit.ps1 -FlushDns
.\WiFi_Repair_Toolkit.ps1 -ForgetProfile 'OldNetwork'
```

## What the repair does

- Restarts WLAN AutoConfig.
- Restarts one selected wireless adapter.
- Releases and renews DHCP for the selected adapter.
- Flushes the DNS resolver cache.
- Removes one explicitly selected saved Wi-Fi profile.
- Captures interface, adapter and IP state before and after repair.
- Supports `-DryRun`, confirmation prompts, logs and clear exit codes.

## Safety and privacy

Connectivity can drop during repair. Removing a profile requires the user to reconnect and re-enter its security key. The tool never exports wireless passwords.

## Author

Dewald Pretorius — L2 IT Support Engineer

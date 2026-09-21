# SMD-CHD - SMD Computer Health Device

## Overview

**SMD Computer Health Device (SMD-CHD)** is a safe, local-only Windows 10/11 diagnostic tool written in Windows PowerShell. It collects read-only health information and presents status results, a health score, and a detailed HTML report for easy review.

This project is designed to help users, ICT students, and technicians perform quick, non-destructive checks on a computer's overall condition.

## Features

- **CPU Diagnostics**: CPU model, cores, logical processors, and current usage
- **RAM Diagnostics**: total, used, available memory, and usage percentage
- **Storage Diagnostics**: capacity, free space, and usage for logical drives
- **GPU Diagnostics (Version 1.1)**: integrated and dedicated GPU detection, including Intel UHD/Iris, AMD, and NVIDIA adapters
- **GPU Driver Information**: adapter RAM/reporting, driver version, and driver date
- **GPU Device Status**: Windows `ConfigManagerErrorCode` checking for each detected GPU
- **Network Testing**: local network, gateway, internet, and DNS checks
- **Windows System Info**: OS version, build, architecture, uptime, and services
- **Security Status**: Microsoft Defender and real-time protection state
- **Hardware Inventory**: computer, CPU, RAM, network, and system information
- **Health Score**: conservative 0-100 score including GPU status
- **Professional HTML Report**: local diagnostic results with a GPU row
- **Safe Operation**: read-only diagnostics only; no driver or system changes

## System Requirements

- **OS**: Windows 10 or Windows 11
- **PowerShell**: Version 5.1 or higher
- **Permissions**: Standard user; administrator is optional for broader diagnostic access
- **Dependencies**: Built-in Windows PowerShell, CIM/WMI, and Windows networking/security cmdlets only

## Installation and Quick Start

1. Clone or download this repository.
2. Extract it to a folder such as `C:\Tools\SMD-CHD`.
3. Run `run.bat`, or execute the PowerShell launcher:

```powershell
Set-ExecutionPolicy -ExecutionPolicy Bypass -Scope Process -Force
.\src\SMD-CHD.ps1
```

## Project Structure

```
SMD-CHD/
├── README.md                 # Documentation
├── run.bat                   # Windows launcher
├── src/
│   ├── SMD-CHD.ps1          # Main launcher, menu, results, and HTML report
│   └─�� modules/
│       ├── CPU.ps1          # CPU diagnostics
│       ├── RAM.ps1           # Memory diagnostics
│       ├── Storage.ps1       # Disk diagnostics
│       ├── Network.ps1       # Network and internet checks
│       ├── Windows.ps1       # Windows system diagnostics
│       ├── Security.ps1      # Microsoft Defender status
│       ├── Inventory.ps1     # Hardware and software inventory
│       ├── GPU.ps1           # Integrated/dedicated GPU diagnostics
│       └── HealthScore.ps1   # Overall score calculation
├── reports/                  # Generated HTML reports
└── logs/                     # Diagnostic logs
```

## Menu Options

1. **Full Computer Health Check** - Run every diagnostic, including GPU, and calculate the score
2. **CPU Check**
3. **RAM Check**
4. **Storage Check**
5. **Network Check**
6. **Windows Check**
7. **Security Check**
8. **Computer Inventory**
9. **GPU Check** - Display all detected adapters and device/driver details
10. **Generate Health Report**
0. **Exit**

## GPU Diagnostics

SMD-CHD queries the built-in `Win32_VideoController` CIM class. This includes integrated GPUs and dedicated GPUs without requiring third-party software. Multiple adapters are enumerated when present.

For each adapter, the GPU check reports the name, reported adapter RAM/VRAM when available, driver version, driver date, and Windows device configuration code. A detected adapter with configuration issues may be displayed as `WARNING` or `CRITICAL` to help identify hardware or driver problems.

## Health Score

The score starts at 100. CPU, RAM, storage, network, and security deductions remain unchanged. GPU issues are deliberately conservative:

- **PASS**: no deduction
- **WARNING**: 4-point deduction
- **CRITICAL**: 10-point deduction
- **INFO**: no deduction

Overall score interpretation: **90-100 Excellent**, **75-89 Good**, **50-74 Needs Attention**, and **0-49 Critical**.

## Reports and Safety

HTML reports are saved in `reports/` as `SMD-CHD-Report_YYYYMMDD_HHmmss.html`. SMD-CHD is read-only: it does not modify GPU drivers, install or remove drivers, change Windows settings, edit the registry, or alter system configuration.

## Testing on Windows 10

From the repository folder, run `run.bat`. Select **9** for the standalone GPU check, then select **1** for a full check and **10** to generate the report. Confirm that the GPU row appears in the generated HTML report.

```powershell
powershell.exe -NoProfile -ExecutionPolicy Bypass -Command ". .\src\modules\GPU.ps1; Get-GPUHealth | Format-List"
```

The command should return `Status`, `Summary`, and `Details` without changing the system.

## Version

**Current Version**: 1.1.0  
**Platform**: Windows 10/11  
**PowerShell**: 5.1+

---

**SMD-CHD: Professional Computer Health Diagnostics - Safe • Local • Reliable**

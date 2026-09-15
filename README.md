# SMD-CHD - SMD Computer Health Device

## Overview

**SMD Computer Health Device (SMD-CHD)** is a professional, lightweight Windows system diagnostics and health monitoring tool designed for Windows 10/11. It provides comprehensive computer health assessments without making any destructive changes to your system.

## Features

- **CPU Diagnostics**: Real-time CPU usage, core count, logical processors
- **RAM Diagnostics**: Memory usage, available RAM, total RAM analysis
- **Storage Diagnostics**: Disk space analysis for all logical drives
- **Network Testing**: Internet connectivity, DNS resolution, gateway information
- **Windows System Info**: OS version, build number, architecture, uptime
- **Security Status**: Microsoft Defender status and real-time protection state
- **Hardware Inventory**: Complete computer hardware and software information
- **Health Score**: Automatic calculation of overall system health (0-100)
- **Professional HTML Report**: Beautiful, detailed health reports saved locally
- **Local Logging**: All diagnostics logged for audit and history
- **Safe Operation**: Zero destructive changes, read-only diagnostics only

## System Requirements

- **OS**: Windows 10 or Windows 11
- **PowerShell**: Version 5.1 or higher (built-in on Windows 10/11)
- **Permissions**: Standard user (admin recommended for full diagnostic access)
- **.NET Framework**: 4.5+ (included with Windows 10/11)

## Installation

1. Clone or download this repository
2. Extract the files to a folder (e.g., `C:\Tools\SMD-CHD`)
3. Run the launcher script

## Quick Start

### Option 1: Using the Batch Launcher (Recommended)

```batch
run.bat
```

### Option 2: Direct PowerShell

```powershell
Set-ExecutionPolicy -ExecutionPolicy Bypass -Scope Process -Force
.\src\SMD-CHD.ps1
```

## Project Structure

```
SMD-CHD/
├── README.md                 # This file
├── run.bat                   # Windows batch launcher
├── src/
│   ├── SMD-CHD.ps1          # Main launcher and menu system
│   └── modules/
│       ├── CPU.ps1          # CPU diagnostics module
│       ├── RAM.ps1          # RAM diagnostics module
│       ├── Storage.ps1      # Storage/disk diagnostics module
│       ├── Network.ps1      # Network and Internet testing module
│       ├── Windows.ps1      # Windows system information module
│       ├── Security.ps1     # Microsoft Defender status module
│       ├── Inventory.ps1    # Hardware and software inventory module
│       └── HealthScore.ps1  # Health score calculation module
├── reports/                 # Generated HTML reports stored here
└── logs/                    # Diagnostic logs stored here
```

## Menu Options

1. **Full Computer Health Check** - Run all diagnostics and generate health score
2. **CPU Check** - Detailed CPU diagnostics
3. **RAM Check** - Detailed RAM diagnostics
4. **Storage Check** - Detailed disk space analysis
5. **Network Check** - Internet and DNS connectivity testing
6. **Windows Check** - Windows OS and system information
7. **Security Check** - Microsoft Defender and antivirus status
8. **Computer Inventory** - Complete hardware and software inventory
9. **Generate Health Report** - Create professional HTML report
0. **Exit** - Close the application

## Health Score Interpretation

- **90-100 (Excellent)**: System is operating optimally
- **75-89 (Good)**: System is healthy with minor issues
- **50-74 (Needs Attention)**: System has notable issues requiring attention
- **0-49 (Critical)**: System has critical issues requiring immediate action

## Output Files

### Reports
HTML reports are saved in the `reports/` folder with naming format:
```
SMD-CHD-Report_YYYYMMDD_HHmmss.html
```

### Logs
Diagnostic logs are saved in the `logs/` folder with naming format:
```
SMD-CHD-Log_YYYYMMDD_HHmmss.txt
```

## Safety

✅ **SMD-CHD is completely safe:**
- Read-only operations only
- No files are deleted
- No system settings are modified
- No registry changes
- No drivers installed/uninstalled
- No destructive commands

## Troubleshooting

### "Execution Policy" Error

If you see an execution policy error, run this command:

```powershell
Set-ExecutionPolicy -ExecutionPolicy Bypass -Scope Process -Force
```

This applies only to the current PowerShell session and doesn't make permanent changes.

### Missing Administrator Rights

Some security features require administrator access. If you see warnings:
1. Right-click Command Prompt or PowerShell
2. Select "Run as Administrator"
3. Navigate to the script folder and run it again

### Microsoft Defender Not Detected

If Defender status cannot be read, you may have a third-party antivirus. The tool will note this in the security check results.

## Features in Detail

### CPU Diagnostics
- Processor model and specifications
- Number of physical cores and logical processors
- Current CPU usage percentage
- Status warnings for high usage (>75%)
- Critical alerts for very high usage (>90%)

### RAM Diagnostics
- Total system RAM in GB
- Currently used RAM
- Available/free RAM
- Usage percentage
- Status warnings for high memory consumption

### Storage Diagnostics
- All logical drives (C:, D:, etc.)
- Total capacity per drive
- Free space per drive
- Used space and percentage
- Alerts for drives over 85% full (warning) or 95% full (critical)

### Network Testing
- Local IPv4 address
- Default gateway
- Internet connectivity test (ping to 8.8.8.8)
- DNS resolution test
- Network adapter information

### Windows Information
- Windows version and edition
- Build number
- System architecture (32-bit or 64-bit)
- System uptime
- Key Windows services status

### Security Status
- Microsoft Defender enabled/disabled status
- Real-time protection state
- Last antivirus signature update time
- Note about alternative antivirus if Defender unavailable

### Hardware Inventory
- Computer name
- Windows version
- CPU model
- Total RAM
- Installed network adapters
- Current IP address
- System uptime

### Health Score
Automatically calculated based on:
- CPU usage levels
- RAM usage levels
- Storage space availability
- Network connectivity
- Windows service status
- Security protection status

Each issue found reduces the score with appropriate deductions.

## Logs and Reports

All diagnostic results are automatically logged for audit and troubleshooting. Reports can be shared with IT support or used for system documentation.

## Support and Issues

For issues, questions, or feature requests, please open an issue on GitHub.

## License

This project is provided as-is for diagnostic and monitoring purposes.

## Version

**Current Version**: 1.0.0
**Release Date**: 2026
**Platform**: Windows 10/11
**PowerShell**: 5.1+

---

**SMD-CHD: Professional Computer Health Diagnostics - Safe • Local • Reliable**

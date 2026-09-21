# SMD-CHD — SMD Computer Health Device

**Version 1.4.0 — Professional diagnostic foundation**

SMD-CHD is a Windows PowerShell 5.1+ computer health diagnostic tool for individual users, ICT students, technicians, repair shops, schools, and small businesses. It performs local, read-only checks and produces a printable SMD Service Report.

## Vision

Build a trustworthy, useful diagnostic product before introducing paid capabilities. SMD-CHD is local-first: it does not upload results, collect credentials, or perform destructive maintenance.

## Version 1.4.0 features

- CPU, RAM, storage, network, Windows, security, inventory, and GPU diagnostics
- Safe battery diagnostics with desktop-aware `INFO` handling
- Thermal diagnostics that never invent temperature values
- Advanced storage information where Windows exposes it, including model/type and physical health
- Transparent 0–100 Health Score for CPU, RAM, Storage, Network, Windows, Security, GPU, Battery, and Thermal
- Real-result recommendations, warnings, and critical issues
- Local diagnostic history and health trend
- Optional Technician Mode fields and a printable **SMD SERVICE REPORT**
- Unique local report IDs and informational maintenance checklist
- Planned Free/Pro architecture without fake payment processing

## Requirements

- Windows 10 or Windows 11
- Windows PowerShell 5.1 or newer
- Standard user is sufficient; some CIM/Defender data may require additional permissions
- No third-party dependencies

## Installation and usage

1. Clone or download the repository.
2. Open the repository folder.
3. Run `run.bat`, or use:

```powershell
Set-ExecutionPolicy -Scope Process Bypass -Force
.\src\SMD-CHD.ps1
```

### Menu

```text
[1] Full Computer Health Check       [10] Battery Health
[2] CPU Check                         [11] Thermal Check
[3] RAM Check                         [12] Health Recommendations
[4] Storage Check                     [13] Diagnostic History
[5] Network Check                     [14] Technician / Service Report
[6] Windows Check                     [15] Generate Professional HTML Report
[7] Security Check                    [0] Exit
[8] Computer Inventory
[9] GPU Check
```

Option 1 runs CPU, RAM, Storage, Network, Windows, Security, Inventory, GPU, Battery, and Thermal, then calculates the score, saves local history, and displays trend information. Option 14 collects optional customer/device/technician/job/note fields; it never automatically collects personal information.

## Project structure

```text
SMD-CHD/
├── README.md
├── run.bat
├── src/
│   ├── SMD-CHD.ps1
│   └── modules/
│       ├── CPU.ps1
│       ├── RAM.ps1
│       ├── Storage.ps1
│       ├── Network.ps1
│       ├── Windows.ps1
│       ├── Security.ps1
│       ├── Inventory.ps1
│       ├── GPU.ps1
│       ├── Battery.ps1
│       ├── Thermal.ps1
│       ├── HealthScore.ps1
│       ├── Recommendations.ps1
│       └── History.ps1
├── reports/                         # Local generated HTML reports
└── logs/history/                    # Local JSON diagnostic summaries
```

## Diagnostics and limitations

### Health Score

The score starts at 100. Only `WARNING` and `CRITICAL` results deduct points. `INFO` results, including a desktop with no battery or hardware without temperature sensors, receive no deduction. The categories and conservative weights are exposed in `HealthScore.ps1`; the report lists every category status.

Status bands are **90–100 Excellent**, **75–89 Good**, **50–74 Needs Attention**, and **0–49 Critical**.

### Battery

SMD-CHD reads Windows battery/CIM data and uses Full Charge Capacity ÷ Design Capacity × 100 when both values exist. Cycle count and charging state are shown only when Windows exposes them. A desktop reports `INFO — No battery detected. Desktop computer.` Battery values are never fabricated.

### Thermal

Windows hardware exposes thermal sensors inconsistently. SMD-CHD reads available ACPI thermal zones and reports `INFO — Temperature data unavailable through this hardware interface.` when none are available. It does not display fake CPU or GPU temperatures.

### Storage and GPU

Storage retains logical-drive capacity/free-space checks and adds read-only model/type and physical health information where built-in Windows interfaces provide it. SMART/physical health may be unavailable. GPU checks enumerate Windows video controllers, device status, driver information, and continue when incomplete.

### Recommendations and history

Recommendations are created only from actual `WARNING` or `CRITICAL` diagnostic results. History is stored locally as JSON under `logs/history/`; no telemetry or cloud service is used. Trend output is omitted in favor of `INFO — No previous diagnostic available.` until a previous diagnostic exists.

## SMD Service Report

Reports are saved in `reports/` and include SMD branding, Version 1.4.0, report ID, date, computer, optional service fields, score/status, all diagnostic categories, problems, recommendations, checklist, trend, and notes. Reports are printable and responsive for desktop/mobile browsers.

## Free and planned Pro architecture

### SMD-CHD FREE

The current product provides CPU, RAM, storage, network, Windows, basic GPU, basic security, inventory, and health score capabilities without artificial feature locks.

### PLANNED SMD-CHD PRO

Potential future value includes professional customer reports, advanced storage diagnostics, battery and thermal diagnostics, history/trends, advanced recommendations, technician mode, report customization, multi-computer management, and business/service-center exports. Version 1.4.0 does **not** pretend payments or licensing are implemented.

## Service-center workflow

A technician can run diagnostics, review the score and real problems, enter optional service information, generate the SMD Service Report, and give the local report to the customer. This supports future technician and repair-shop licensing without requiring cloud accounts today.

Potential legitimate revenue models are Pro licenses, technician licenses, repair-shop packages, small-business IT packages, professional report services, custom enterprise features, and IT support services powered by SMD-CHD. No deceptive monetization or credit-card collection is implemented.

## Privacy, security, and safety

SMD-CHD is **LOCAL-FIRST, READ-ONLY, NO TELEMETRY, NO TRACKING, NO PASSWORD COLLECTION, NO CREDENTIAL COLLECTION, NO AUTOMATIC CLOUD UPLOAD, NO REGISTRY MODIFICATION, NO DRIVER INSTALLATION, NO DISK REPAIR, and NO DESTRUCTIVE OPERATIONS**. It uses built-in Windows PowerShell/CIM/WMI and networking/security interfaces. Diagnostic access can be limited by Windows permissions or hardware support.

## Testing and limitations

The implementation is designed for PowerShell 5.1 syntax and defensive handling of missing battery, thermal, SMART, GPU, Defender, service, network, and CIM data. Runtime hardware validation must be performed on representative Windows 10 desktops, Windows 10 laptops, Windows 11 desktops, and Windows 11 laptops. PowerShell itself is not available in this Linux-based editing environment, so final syntax validation should be run on Windows with:

```powershell
powershell.exe -NoProfile -ExecutionPolicy Bypass -Command ". .\src\SMD-CHD.ps1"
```

Because the main script is interactive, use the application menu for functional verification. Optional Windows interfaces can return `INFO` even when hardware is healthy.

## Roadmap

- **Version 1.4.0:** Professional diagnostic foundation.
- **Version 1.5:** Potential better dashboard, improved reports, more hardware diagnostics, and better service workflow.
- **Version 2.0:** Potential SMD-CHD Pro licensing, technician accounts, multi-computer management, business management, optional cloud services, secure online features, and paid licensing. These online services are not implemented or simulated in 1.4.0.

## Disclaimer

SMD-CHD is an informational diagnostic aid, not a substitute for qualified technical inspection, manufacturer service procedures, backups, or professional security advice. Results depend on Windows permissions and hardware interfaces.

**SMD-CHD — Safe • Local • Reliable**

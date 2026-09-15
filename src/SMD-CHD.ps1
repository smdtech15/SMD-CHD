# ============================================================
# SMD-CHD - SMD Computer Health Device
# Main Launcher and Menu System - Version 1.0.0
# ============================================================
# This is the main entry point for SMD-CHD.
# It loads all modules and provides the interactive menu.

$ErrorActionPreference = 'Continue'
$ScriptRoot = Split-Path -Parent $MyInvocation.MyCommand.Path
$ModulesPath = Join-Path $ScriptRoot 'modules'
$ReportsPath = Join-Path (Split-Path $ScriptRoot -Parent) 'reports'
$LogsPath = Join-Path (Split-Path $ScriptRoot -Parent) 'logs'

# Create required folders if they don't exist
@($ReportsPath, $LogsPath) | ForEach-Object {
    if (-not (Test-Path $_)) {
        New-Item -ItemType Directory -Path $_ -Force | Out-Null
    }
}

# Load all module files
$moduleFiles = @(
    'CPU.ps1',
    'RAM.ps1',
    'Storage.ps1',
    'Network.ps1',
    'Windows.ps1',
    'Security.ps1',
    'Inventory.ps1',
    'HealthScore.ps1'
)

foreach ($mod in $moduleFiles) {
    $path = Join-Path $ModulesPath $mod
    if (Test-Path $path) {
        . $path
    } else {
        Write-Host "[WARNING] Module missing: $mod" -ForegroundColor Yellow
    }
}

# Global results object
$Global:SMDResults = @{
    CPU = $null
    RAM = $null
    Storage = $null
    Network = $null
    Windows = $null
    Security = $null
    Inventory = $null
    HealthScore = $null
    Timestamp = Get-Date
}

function Show-Banner {
    Clear-Host
    Write-Host '========================================' -ForegroundColor Cyan
    Write-Host '           SMD-CHD' -ForegroundColor White
    Write-Host '   SMD COMPUTER HEALTH DEVICE' -ForegroundColor Cyan
    Write-Host '========================================' -ForegroundColor Cyan
    Write-Host ''
    Write-Host '  Computer Health Diagnostic System' -ForegroundColor Gray
    Write-Host '  Version 1.0.0 | Safe & Local Only' -ForegroundColor DarkGray
    Write-Host ''
}

function Show-Menu {
    Write-Host '----------------------------------------' -ForegroundColor DarkCyan
    Write-Host '  [1] Full Computer Health Check'
    Write-Host '  [2] CPU Check'
    Write-Host '  [3] RAM Check'
    Write-Host '  [4] Storage Check'
    Write-Host '  [5] Network Check'
    Write-Host '  [6] Windows Check'
    Write-Host '  [7] Security Check'
    Write-Host '  [8] Computer Inventory'
    Write-Host '  [9] Generate Health Report'
    Write-Host '  [0] Exit'
    Write-Host '----------------------------------------' -ForegroundColor DarkCyan
    Write-Host ''
}

function Write-Status {
    param(
        [string]$Status,
        [string]$Message
    )
    
    switch ($Status.ToUpper()) {
        'PASS' {
            Write-Host '[ PASS     ] ' -ForegroundColor Green -NoNewline
        }
        'WARNING' {
            Write-Host '[ WARNING  ] ' -ForegroundColor Yellow -NoNewline
        }
        'CRITICAL' {
            Write-Host '[ CRITICAL ] ' -ForegroundColor Red -NoNewline
        }
        'INFO' {
            Write-Host '[ INFO     ] ' -ForegroundColor Cyan -NoNewline
        }
        default {
            Write-Host "[ $Status ] " -NoNewline
        }
    }
    Write-Host $Message
}

function Run-FullCheck {
    Write-Host "`n>>> Running Full Computer Health Check...`n" -ForegroundColor Cyan

    $Global:SMDResults.CPU = Get-CPUHealth
    $Global:SMDResults.RAM = Get-RAMHealth
    $Global:SMDResults.Storage = Get-StorageHealth
    $Global:SMDResults.Network = Get-NetworkHealth
    $Global:SMDResults.Windows = Get-WindowsHealth
    $Global:SMDResults.Security = Get-SecurityHealth
    $Global:SMDResults.Inventory = Get-ComputerInventory
    $Global:SMDResults.HealthScore = Get-HealthScore -Results $Global:SMDResults
    $Global:SMDResults.Timestamp = Get-Date

    $hs = $Global:SMDResults.HealthScore
    Write-Host '========== HEALTH SUMMARY ==========' -ForegroundColor Cyan
    Write-Host "Overall Health Score : $($hs.Score) / 100"
    
    $statusColor = switch ($hs.Status) {
        'Excellent' { 'Green' }
        'Good' { 'Green' }
        'Needs Attention' { 'Yellow' }
        'Critical' { 'Red' }
        default { 'White' }
    }
    
    Write-Host "Status               : $($hs.Status)" -ForegroundColor $statusColor
    Write-Host ''
    Write-Host 'Press any key to continue...'
    $null = $Host.UI.RawUI.ReadKey('NoEcho,IncludeKeyDown')
}

function Generate-HTMLReport {
    if (-not $Global:SMDResults.HealthScore) {
        Write-Host 'Please run Full Health Check first (option 1).' -ForegroundColor Yellow
        Write-Host 'Press any key to continue...'
        $null = $Host.UI.RawUI.ReadKey('NoEcho,IncludeKeyDown')
        return
    }

    $reportFile = Join-Path $ReportsPath ('SMD-CHD-Report_{0}.html' -f (Get-Date -Format 'yyyyMMdd_HHmmss'))
    $inv = $Global:SMDResults.Inventory
    $hs = $Global:SMDResults.HealthScore

    $recsHtml = ''
    if ($hs.Recommendations -and $hs.Recommendations.Count -gt 0) {
        foreach ($r in $hs.Recommendations) {
            $recsHtml += "<div class='rec'>$r</div>`n"
        }
    } else {
        $recsHtml = "<div class='rec'>No major issues detected. System looks healthy.</div>"
    }

    $html = @"
<!DOCTYPE html>
<html lang="en">
<head>
<meta charset="UTF-8">
<meta name="viewport" content="width=device-width, initial-scale=1.0">
<title>SMD-CHD Health Report</title>
<style>
body{font-family:'Segoe UI',Arial,sans-serif;background:#0f172a;color:#e2e8f0;margin:0;padding:20px}
.container{max-width:900px;margin:0 auto;background:#1e293b;border-radius:12px;padding:30px;box-shadow:0 10px 40px rgba(0,0,0,.4)}
h1{color:#38bdf8;margin-bottom:5px;font-size:28px}
.subtitle{color:#94a3b8;margin-top:0;margin-bottom:15px}
.metadata{color:#94a3b8;font-size:14px;margin-bottom:20px}
.score-box{background:#0f172a;border-radius:10px;padding:20px;text-align:center;margin:25px 0;border:2px solid #38bdf8}
.score{font-size:48px;font-weight:bold;color:#38bdf8}
.status{font-size:22px;margin-top:8px;font-weight:bold}
.section{margin:25px 0}
.section h2{color:#38bdf8;border-bottom:1px solid #334155;padding-bottom:8px;font-size:18px}
table{width:100%;border-collapse:collapse;margin-top:10px}
th,td{padding:10px 12px;text-align:left;border-bottom:1px solid #334155}
th{color:#94a3b8;background:#0f172a;font-weight:bold}
.pass{color:#4ade80;font-weight:bold}
.warning{color:#facc15;font-weight:bold}
.critical{color:#f87171;font-weight:bold}
.info{color:#38bdf8;font-weight:bold}
.rec{background:#0f172a;padding:12px 15px;border-radius:8px;margin:8px 0;border-left:4px solid #facc15;color:#e2e8f0}
.footer{margin-top:40px;text-align:center;color:#64748b;font-size:13px;border-top:1px solid #334155;padding-top:20px}
</style>
</head>
<body>
<div class="container">
<h1>SMD-CHD</h1>
<p class="subtitle">SMD Computer Health Device - Diagnostic Report</p>
<p class="metadata"><strong>Computer:</strong> $($inv.ComputerName) &nbsp;|&nbsp; <strong>Date:</strong> $($Global:SMDResults.Timestamp.ToString('yyyy-MM-dd HH:mm:ss'))</p>

<div class="score-box">
<div class="score">$($hs.Score)</div>
<div class="status">$($hs.Status)</div>
</div>

<div class="section">
<h2>System Inventory</h2>
<table>
<tr><th>Item</th><th>Value</th></tr>
<tr><td>Computer Name</td><td>$($inv.ComputerName)</td></tr>
<tr><td>Windows Version</td><td>$($inv.WindowsVersion)</td></tr>
<tr><td>Architecture</td><td>$($inv.Architecture)</td></tr>
<tr><td>CPU</td><td>$($inv.CPU)</td></tr>
<tr><td>RAM</td><td>$($inv.RAM)</td></tr>
<tr><td>Uptime</td><td>$($inv.Uptime)</td></tr>
</table>
</div>

<div class="section">
<h2>Diagnostic Results</h2>
<table>
<tr><th>Component</th><th>Status</th><th>Details</th></tr>
<tr><td>CPU</td><td class="$($Global:SMDResults.CPU.Status.ToLower())">$($Global:SMDResults.CPU.Status)</td><td>$($Global:SMDResults.CPU.Summary)</td></tr>
<tr><td>RAM</td><td class="$($Global:SMDResults.RAM.Status.ToLower())">$($Global:SMDResults.RAM.Status)</td><td>$($Global:SMDResults.RAM.Summary)</td></tr>
<tr><td>Storage</td><td class="$($Global:SMDResults.Storage.Status.ToLower())">$($Global:SMDResults.Storage.Status)</td><td>$($Global:SMDResults.Storage.Summary)</td></tr>
<tr><td>Network</td><td class="$($Global:SMDResults.Network.Status.ToLower())">$($Global:SMDResults.Network.Status)</td><td>$($Global:SMDResults.Network.Summary)</td></tr>
<tr><td>Windows</td><td class="$($Global:SMDResults.Windows.Status.ToLower())">$($Global:SMDResults.Windows.Status)</td><td>$($Global:SMDResults.Windows.Summary)</td></tr>
<tr><td>Security</td><td class="$($Global:SMDResults.Security.Status.ToLower())">$($Global:SMDResults.Security.Status)</td><td>$($Global:SMDResults.Security.Summary)</td></tr>
</table>
</div>

<div class="section">
<h2>Recommendations</h2>
$recsHtml
</div>

<div class="footer">
Generated by <strong>SMD-CHD</strong> - SMD Computer Health Device<br>
Safe &bull; Local &bull; Professional Diagnostic Tool<br>
Version 1.0.0
</div>
</div>
</body>
</html>
"@

    $html | Out-File -FilePath $reportFile -Encoding UTF8
    Write-Host "`nReport generated successfully!" -ForegroundColor Green
    Write-Host "Location: $reportFile" -ForegroundColor Cyan
    
    try {
        Start-Process $reportFile
    } catch {
        Write-Host "Could not open report automatically, but it was saved." -ForegroundColor Yellow
    }
    
    Write-Host 'Press any key to continue...'
    $null = $Host.UI.RawUI.ReadKey('NoEcho,IncludeKeyDown')
}

# Main loop
$running = $true
while ($running) {
    Show-Banner
    Show-Menu
    $choice = Read-Host 'Select an option'

    switch ($choice) {
        '1' {
            Run-FullCheck
        }
        '2' {
            $r = Get-CPUHealth
            Write-Host ''
            Write-Status $r.Status $r.Summary
            $r.Details | ForEach-Object { Write-Host "  $_" }
            Write-Host ''
            Write-Host 'Press any key to continue...'
            $null = $Host.UI.RawUI.ReadKey('NoEcho,IncludeKeyDown')
        }
        '3' {
            $r = Get-RAMHealth
            Write-Host ''
            Write-Status $r.Status $r.Summary
            $r.Details | ForEach-Object { Write-Host "  $_" }
            Write-Host ''
            Write-Host 'Press any key to continue...'
            $null = $Host.UI.RawUI.ReadKey('NoEcho,IncludeKeyDown')
        }
        '4' {
            $r = Get-StorageHealth
            Write-Host ''
            Write-Status $r.Status $r.Summary
            $r.Details | ForEach-Object { Write-Host "  $_" }
            Write-Host ''
            Write-Host 'Press any key to continue...'
            $null = $Host.UI.RawUI.ReadKey('NoEcho,IncludeKeyDown')
        }
        '5' {
            $r = Get-NetworkHealth
            Write-Host ''
            Write-Status $r.Status $r.Summary
            $r.Details | ForEach-Object { Write-Host "  $_" }
            Write-Host ''
            Write-Host 'Press any key to continue...'
            $null = $Host.UI.RawUI.ReadKey('NoEcho,IncludeKeyDown')
        }
        '6' {
            $r = Get-WindowsHealth
            Write-Host ''
            Write-Status $r.Status $r.Summary
            $r.Details | ForEach-Object { Write-Host "  $_" }
            Write-Host ''
            Write-Host 'Press any key to continue...'
            $null = $Host.UI.RawUI.ReadKey('NoEcho,IncludeKeyDown')
        }
        '7' {
            $r = Get-SecurityHealth
            Write-Host ''
            Write-Status $r.Status $r.Summary
            $r.Details | ForEach-Object { Write-Host "  $_" }
            Write-Host ''
            Write-Host 'Press any key to continue...'
            $null = $Host.UI.RawUI.ReadKey('NoEcho,IncludeKeyDown')
        }
        '8' {
            $r = Get-ComputerInventory
            Write-Host "`n=== COMPUTER INVENTORY ===" -ForegroundColor Cyan
            $r.GetEnumerator() | Sort-Object Name | ForEach-Object {
                Write-Host ('{0,-22}: {1}' -f $_.Key, $_.Value)
            }
            Write-Host ''
            Write-Host 'Press any key to continue...'
            $null = $Host.UI.RawUI.ReadKey('NoEcho,IncludeKeyDown')
        }
        '9' {
            Generate-HTMLReport
        }
        '0' {
            Write-Host "`nThank you for using SMD-CHD. Goodbye!" -ForegroundColor Cyan
            $running = $false
        }
        default {
            Write-Host 'Invalid option.' -ForegroundColor Yellow
            Start-Sleep -Seconds 1
        }
    }
}

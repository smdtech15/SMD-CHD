# ============================================================
# History.ps1 - Local diagnostic history and trend support
# ============================================================
function Get-DiagnosticHistoryPath { param([string]$LogsPath) $path = Join-Path $LogsPath 'history'; if (-not (Test-Path $path)) { New-Item -ItemType Directory -Path $path -Force | Out-Null }; return $path }
function Save-DiagnosticHistory {
    param([Parameter(Mandatory=$true)]$Results,[Parameter(Mandatory=$true)]$HealthScore,[Parameter(Mandatory=$true)][string]$LogsPath)
    try {
        $path = Get-DiagnosticHistoryPath $LogsPath
        $record = [PSCustomObject]@{ DateTime=(Get-Date).ToString('o'); ComputerName=[Environment]::MachineName; Score=$HealthScore.Score; Status=$HealthScore.Status; Warnings=@($HealthScore.Warnings); CriticalIssues=@($HealthScore.CriticalIssues) }
        $file = Join-Path $path ('diagnostic_{0}.json' -f (Get-Date -Format 'yyyyMMdd_HHmmss_fff'))
        $record | ConvertTo-Json -Depth 5 | Out-File -FilePath $file -Encoding UTF8
        return $record
    } catch { return $null }
}
function Get-PreviousDiagnostic { param([string]$LogsPath)
    try { $files = @(Get-ChildItem -Path (Get-DiagnosticHistoryPath $LogsPath) -Filter 'diagnostic_*.json' -File | Sort-Object LastWriteTime -Descending); if ($files.Count -lt 2) { return $null }; return (Get-Content -Raw -Path $files[1].FullName | ConvertFrom-Json) } catch { return $null }
}
function Get-HealthTrend { param([string]$LogsPath,[int]$CurrentScore)
    $previous = Get-PreviousDiagnostic $LogsPath
    if (-not $previous) { return [PSCustomObject]@{ PreviousScore=$null; CurrentScore=$CurrentScore; Change=$null; Summary='INFO — No previous diagnostic available.' } }
    $change = $CurrentScore - [int]$previous.Score; $sign = if ($change -ge 0) { '+' } else { '' }
    return [PSCustomObject]@{ PreviousScore=[int]$previous.Score; CurrentScore=$CurrentScore; Change=$change; Summary="Previous Score: $($previous.Score) | Current Score: $CurrentScore | Change: $sign$change" }
}

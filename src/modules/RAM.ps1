# ============================================================
# RAM.ps1 - RAM Diagnostics Module
# ============================================================

function Get-RAMHealth {
    $status = 'PASS'
    $details = @()
    $summary = ''
    $usagePct = 0

    try {
        $os = Get-CimInstance Win32_OperatingSystem
        $totalGB = [math]::Round($os.TotalVisibleMemorySize / 1MB, 2)
        $freeGB = [math]::Round($os.FreePhysicalMemory / 1MB, 2)
        $usedGB = [math]::Round($totalGB - $freeGB, 2)
        $usagePct = [math]::Round(($usedGB / $totalGB) * 100, 1)

        $details += "Total RAM      : $totalGB GB"
        $details += "Used RAM       : $usedGB GB"
        $details += "Available RAM  : $freeGB GB"
        $details += "Usage          : $usagePct%"

        if ($usagePct -ge 92) {
            $status = 'CRITICAL'
            $summary = "RAM usage is critically high ($usagePct%)"
        } elseif ($usagePct -ge 80) {
            $status = 'WARNING'
            $summary = "RAM usage is high ($usagePct%)"
        } else {
            $summary = "RAM is healthy ($usagePct% used)"
        }
    } catch {
        $status = 'WARNING'
        $summary = 'Could not read RAM information'
        $details += "Error: $($_.Exception.Message)"
    }

    return [PSCustomObject]@{
        Status = $status
        Summary = $summary
        Details = $details
        UsagePct = $usagePct
    }
}

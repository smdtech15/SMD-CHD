# ============================================================
# CPU.ps1 - CPU Diagnostics Module
# ============================================================

function Get-CPUHealth {
    $status = 'PASS'
    $details = @()
    $summary = ''
    $usage = 0

    try {
        $cpu = Get-CimInstance Win32_Processor | Select-Object -First 1
        $usage = (Get-CimInstance Win32_Processor | Measure-Object -Property LoadPercentage -Average).Average

        if ($null -eq $usage) {
            $usage = 0
        }

        $details += "Model          : $($cpu.Name)"
        $details += "Cores          : $($cpu.NumberOfCores)"
        $details += "Logical CPUs   : $($cpu.NumberOfLogicalProcessors)"
        $details += "Current Usage  : $([math]::Round($usage, 1))%"

        if ($usage -ge 90) {
            $status = 'CRITICAL'
            $summary = "CPU usage is very high ($([math]::Round($usage, 1))%)"
        } elseif ($usage -ge 75) {
            $status = 'WARNING'
            $summary = "CPU usage is high ($([math]::Round($usage, 1))%)"
        } else {
            $summary = "CPU is healthy ($([math]::Round($usage, 1))% usage)"
        }
    } catch {
        $status = 'WARNING'
        $summary = 'Could not fully read CPU information'
        $details += "Error: $($_.Exception.Message)"
    }

    return [PSCustomObject]@{
        Status = $status
        Summary = $summary
        Details = $details
        Usage = $usage
    }
}

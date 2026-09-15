# ============================================================
# Windows.ps1 - Windows System Information Module
# ============================================================

function Get-WindowsHealth {
    $status = 'PASS'
    $details = @()
    $summary = 'Windows system looks normal'

    try {
        $os = Get-CimInstance Win32_OperatingSystem
        $details += "Windows Version : $($os.Caption)"
        $details += "Build           : $($os.BuildNumber)"
        $details += "Architecture    : $($os.OSArchitecture)"

        # Calculate uptime
        $uptime = (Get-Date) - $os.LastBootUpTime
        $details += "Uptime          : $($uptime.Days) days, $($uptime.Hours) hours"

        # Check important Windows services
        $services = @('wuauserv', 'bits', 'LanmanServer')
        foreach ($svcName in $services) {
            $svc = Get-Service -Name $svcName -ErrorAction SilentlyContinue
            if ($svc) {
                $svcStatus = $svc.Status.ToString()
                $details += "Service $svcName   : $svcStatus"
            }
        }
    } catch {
        $status = 'WARNING'
        $summary = 'Could not fully read Windows information'
        $details += "Error: $($_.Exception.Message)"
    }

    return [PSCustomObject]@{
        Status = $status
        Summary = $summary
        Details = $details
    }
}

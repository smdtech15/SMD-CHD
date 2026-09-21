# ============================================================
# Battery.ps1 - Safe, read-only battery diagnostics
# ============================================================
function Get-BatteryHealth {
    $details = @()
    try {
        $batteries = @(Get-CimInstance -ClassName Win32_Battery -ErrorAction SilentlyContinue)
        if ($batteries.Count -eq 0) {
            return [PSCustomObject]@{ Status='INFO'; Summary='No battery detected. Desktop computer.'; Details=@('Battery diagnostics are not applicable on this computer.'); HealthPct=$null; Batteries=@() }
        }

        $items = @(); $worst = 'PASS'; $healthValues = @()
        foreach ($battery in $batteries) {
            $name = if ($battery.Name) { [string]$battery.Name } else { 'Battery' }
            $statusText = switch ([int]$battery.BatteryStatus) { 1 {'Discharging'} 2 {'AC power / charging'} 3 {'Fully charged'} 4 {'Low'} 5 {'Critical'} 6 {'Charging'} 7 {'Charging, high'} 8 {'Charging, low'} 9 {'Charging, critical'} 10 {'Undefined'} 11 {'Partially charged'} default {'Not reported'} }
            $design = $null; $full = $null; $cycle = $null
            try { $static = Get-CimInstance -Namespace 'root\wmi' -ClassName BatteryStaticData -ErrorAction Stop | Select-Object -First 1; if ($static.DesignedCapacity) { $design = [double]$static.DesignedCapacity } } catch {}
            try { $charged = Get-CimInstance -Namespace 'root\wmi' -ClassName BatteryFullChargedCapacity -ErrorAction Stop | Select-Object -First 1; if ($charged.FullChargedCapacity) { $full = [double]$charged.FullChargedCapacity } } catch {}
            try { $cycleData = Get-CimInstance -Namespace 'root\wmi' -ClassName BatteryCycleCount -ErrorAction Stop | Select-Object -First 1; if ($cycleData.CycleCount -ne $null) { $cycle = [int]$cycleData.CycleCount } } catch {}
            $health = $null
            if ($design -gt 0 -and $full -ge 0) { $health = [math]::Round(($full / $design) * 100, 1); $healthValues += $health }
            $item = [PSCustomObject]@{ Name=$name; Status=$statusText; DesignCapacity=$design; FullChargeCapacity=$full; HealthPct=$health; CycleCount=$cycle }
            $items += $item
            $details += "Battery        : $name"
            $details += "Status         : $statusText"
            $details += "Design Capacity: $(if ($design) { '{0:N0} mWh' -f $design } else { 'Not reported' })"
            $details += "Full Capacity  : $(if ($full) { '{0:N0} mWh' -f $full } else { 'Not reported' })"
            $details += "Health         : $(if ($null -ne $health) { "$health%" } else { 'Not available' })"
            $details += "Cycle Count    : $(if ($null -ne $cycle) { $cycle } else { 'Not reported' })"
            if ($health -ne $null -and $health -lt 50) { $worst = 'CRITICAL' } elseif ($health -ne $null -and $health -lt 80 -and $worst -ne 'CRITICAL') { $worst = 'WARNING' }
        }
        $average = if ($healthValues.Count) { [math]::Round(($healthValues | Measure-Object -Average).Average, 1) } else { $null }
        $summary = if ($average -ne $null) { "Battery health is $average%" } else { 'Battery detected; capacity health is not available through this hardware interface' }
        if ($average -eq $null) { $worst = 'INFO' }
        return [PSCustomObject]@{ Status=$worst; Summary=$summary; Details=$details; HealthPct=$average; Batteries=$items }
    } catch {
        return [PSCustomObject]@{ Status='INFO'; Summary='Battery information could not be retrieved'; Details=@("Battery diagnostics were unavailable: $($_.Exception.Message)"); HealthPct=$null; Batteries=@() }
    }
}

# ============================================================
# Thermal.ps1 - Safe, read-only thermal diagnostics
# ============================================================
function Get-ThermalHealth {
    $details = @(); $readings = @()
    try {
        try {
            $zones = @(Get-CimInstance -Namespace 'root\wmi' -ClassName MSAcpi_ThermalZoneTemperature -ErrorAction Stop)
            foreach ($zone in $zones) {
                if ($zone.CurrentTemperature -gt 0) {
                    $c = [math]::Round(($zone.CurrentTemperature / 10) - 273.15, 1)
                    $readings += [PSCustomObject]@{ Source='System thermal zone'; Celsius=$c }
                    $details += "System temperature: $c C (ACPI thermal zone)"
                }
            }
        } catch {}
        if ($readings.Count -eq 0) {
            return [PSCustomObject]@{ Status='INFO'; Summary='Temperature data unavailable through this hardware interface.'; Details=@('Windows did not expose CPU, GPU, or system temperature readings through the available built-in interfaces.'); Readings=@() }
        }
        $max = ($readings | Measure-Object -Property Celsius -Maximum).Maximum
        $status = if ($max -ge 90) { 'CRITICAL' } elseif ($max -ge 80) { 'WARNING' } else { 'PASS' }
        $summary = if ($status -eq 'PASS') { "Available thermal readings are within the normal range (maximum $max C)" } elseif ($status -eq 'WARNING') { "Available thermal readings indicate possible heat (maximum $max C)" } else { "Available thermal readings indicate overheating risk (maximum $max C)" }
        return [PSCustomObject]@{ Status=$status; Summary=$summary; Details=$details; Readings=$readings }
    } catch {
        return [PSCustomObject]@{ Status='INFO'; Summary='Temperature data unavailable through this hardware interface.'; Details=@("Thermal diagnostics were unavailable: $($_.Exception.Message)"); Readings=@() }
    }
}

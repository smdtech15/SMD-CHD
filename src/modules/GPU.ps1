# ============================================================
# GPU.ps1 - GPU Diagnostics Module
# ============================================================

function Convert-GPUDriverDate {
    param(
        [Parameter(Mandatory = $false)]
        $Value
    )

    if ($null -eq $Value -or [string]::IsNullOrWhiteSpace([string]$Value)) {
        return 'Not available'
    }

    try {
        if ($Value -is [datetime]) {
            return $Value.ToString('yyyy-MM-dd')
        }

        $dateText = [string]$Value
        if ($dateText -match '^\d{14}(?:\.\d{6})?[+-]\d{3,4}$') {
            return ([System.Management.ManagementDateTimeConverter]::ToDateTime($dateText)).ToString('yyyy-MM-dd')
        }

        return ([datetime]::Parse($dateText)).ToString('yyyy-MM-dd')
    } catch {
        return [string]$Value
    }
}

function Get-GPUHealth {
    $status = 'PASS'
    $details = @()
    $summary = 'GPU configuration looks healthy'

    try {
        # Win32_VideoController reports integrated and dedicated adapters alike.
        $adapters = @(Get-CimInstance -ClassName Win32_VideoController -ErrorAction Stop)

        if ($adapters.Count -eq 0) {
            return [PSCustomObject]@{
                Status = 'INFO'
                Summary = 'No GPU information was returned by Windows'
                Details = @('Windows did not return any Win32_VideoController entries; no changes were made.')
            }
        }

        $problemAdapters = @()
        foreach ($adapter in $adapters) {
            $name = if ($adapter.Name) { [string]$adapter.Name } else { 'Unknown GPU' }
            $ram = 'Not reported'
            if ($null -ne $adapter.AdapterRAM -and $adapter.AdapterRAM -gt 0) {
                $ram = '{0:N2} GB' -f ($adapter.AdapterRAM / 1GB)
            }
            $driverDate = Convert-GPUDriverDate -Value $adapter.DriverDate
            $configCode = if ($null -ne $adapter.ConfigManagerErrorCode) {
                [int]$adapter.ConfigManagerErrorCode
            } else {
                'Not reported'
            }

            $details += "GPU            : $name"
            $details += "Adapter RAM    : $ram"
            $details += "Driver Version : $(if ($adapter.DriverVersion) { $adapter.DriverVersion } else { 'Not reported' })"
            $details += "Driver Date    : $driverDate"
            $details += "Device Status  : ConfigManagerErrorCode $configCode"

            if ($configCode -is [int] -and $configCode -ne 0) {
                $problemAdapters += [PSCustomObject]@{
                    Name = $name
                    Code = $configCode
                }
            }
        }

        if ($problemAdapters.Count -gt 0) {
            $criticalCodes = @(10, 12, 14, 18, 24, 28, 29, 31, 32, 43, 44, 45, 46)
            $hasCritical = $problemAdapters | Where-Object { $_.Code -in $criticalCodes }
            if ($hasCritical) {
                $status = 'CRITICAL'
                $summary = 'One or more GPUs report a serious Windows device configuration problem'
            } else {
                $status = 'WARNING'
                $summary = 'One or more GPUs report a Windows device configuration warning'
            }
            foreach ($problem in $problemAdapters) {
                $details += "Problem         : $($problem.Name) reports configuration code $($problem.Code)"
            }
        } elseif ($adapters.Count -eq 1) {
            $summary = 'GPU detected and Windows reports no device configuration problem'
        } else {
            $summary = "$($adapters.Count) GPUs detected and Windows reports no device configuration problems"
        }
    } catch {
        $status = 'INFO'
        $summary = 'GPU information could not be retrieved'
        $details += 'Windows GPU diagnostics could not complete; the application will continue safely.'
        $details += "Error: $($_.Exception.Message)"
    }

    return [PSCustomObject]@{
        Status = $status
        Summary = $summary
        Details = $details
    }
}

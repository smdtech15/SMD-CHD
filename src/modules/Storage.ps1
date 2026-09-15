# ============================================================
# Storage.ps1 - Storage and Disk Diagnostics Module
# ============================================================

function Get-StorageHealth {
    $status = 'PASS'
    $details = @()
    $summary = 'Storage looks healthy'
    $worstStatus = 'PASS'

    try {
        $disks = Get-CimInstance Win32_LogicalDisk -Filter 'DriveType=3'
        
        if ($null -eq $disks) {
            $status = 'WARNING'
            $summary = 'No logical drives found'
            $details += 'Could not enumerate drives'
            return [PSCustomObject]@{
                Status = $status
                Summary = $summary
                Details = $details
            }
        }

        foreach ($d in $disks) {
            $totalGB = [math]::Round($d.Size / 1GB, 2)
            $freeGB = [math]::Round($d.FreeSpace / 1GB, 2)
            $usedPct = if ($d.Size -gt 0) {
                [math]::Round((($d.Size - $d.FreeSpace) / $d.Size) * 100, 1)
            } else {
                0
            }

            $line = "$($d.DeviceID)  Total: $totalGB GB | Free: $freeGB GB | Used: $usedPct%"
            $details += $line

            if ($usedPct -ge 95) {
                $worstStatus = 'CRITICAL'
                $summary = "Drive $($d.DeviceID) is almost full ($usedPct%)"
            } elseif ($usedPct -ge 85 -and $worstStatus -ne 'CRITICAL') {
                $worstStatus = 'WARNING'
                $summary = "Drive $($d.DeviceID) is getting full ($usedPct%)"
            }
        }
        $status = $worstStatus
    } catch {
        $status = 'WARNING'
        $summary = 'Could not read storage information'
        $details += "Error: $($_.Exception.Message)"
    }

    return [PSCustomObject]@{
        Status = $status
        Summary = $summary
        Details = $details
    }
}

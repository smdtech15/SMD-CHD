# ============================================================
# Storage.ps1 - Storage and disk diagnostics
# ============================================================
function Get-StorageHealth {
    $details=@(); $disks=@(); $status='PASS'; $summary='Storage looks healthy'; $systemDrive = $env:SystemDrive
    try {
        $logical = @(Get-CimInstance Win32_LogicalDisk -Filter 'DriveType=3' -ErrorAction Stop)
        if ($logical.Count -eq 0) { return [PSCustomObject]@{Status='INFO';Summary='No fixed logical drives were returned';Details=@('Storage information was not available.');Disks=@();SystemDrive=$systemDrive} }
        foreach ($d in $logical) {
            $total = if ($d.Size) { [math]::Round($d.Size / 1GB,2) } else { 0 }; $free = if ($d.FreeSpace) { [math]::Round($d.FreeSpace / 1GB,2) } else { 0 }; $used = if ($d.Size -gt 0) { [math]::Round((($d.Size-$d.FreeSpace)/$d.Size)*100,1) } else { 0 }
            $disk = [PSCustomObject]@{ Drive=$d.DeviceID; CapacityGB=$total; FreeGB=$free; UsedPct=$used; Model='Not reported'; DiskType='Not reported'; PhysicalHealth='Not available'; SmartInfo='Not available' }; $disks += $disk
            $details += "$($d.DeviceID)  Capacity: $total GB | Free: $free GB | Used: $used%$(if ($d.DeviceID -eq $systemDrive) {' | System drive'} else {''})"
            if ($used -ge 95) { $status='CRITICAL'; $summary="Drive $($d.DeviceID) is critically full ($used%)" } elseif ($used -ge 85 -and $status -ne 'CRITICAL') { $status='WARNING'; $summary="Drive $($d.DeviceID) is getting full ($used%)" }
        }
        try {
            $physical = @(Get-CimInstance -ClassName Win32_DiskDrive -ErrorAction Stop)
            foreach ($p in $physical) {
                $type = if ([string]$p.MediaType -match 'SSD|Solid') {'SSD'} elseif ([string]$p.MediaType -match 'Fixed') {'HDD/Fixed'} else {'Not reported'}
                $match = $disks | Select-Object -First 1; if ($match) { $match.Model=if($p.Model){$p.Model.Trim()}else{'Not reported'}; $match.DiskType=$type }
            }
            $details += 'Physical disk model/type: read-only information retrieved where Windows exposed it.'
        } catch { $details += 'Physical disk model/type: INFO - unavailable through this interface.' }
        try {
            $physicalDisks = @(Get-PhysicalDisk -ErrorAction Stop)
            foreach ($p in $physicalDisks) { $details += "Physical health: $($p.FriendlyName) — $($p.HealthStatus)"; if ($p.HealthStatus -notin @('Healthy','')) { if ($status -eq 'PASS') {$status='WARNING'} } }
        } catch { $details += 'SMART/physical health: INFO - advanced storage health is unavailable.' }
        return [PSCustomObject]@{Status=$status;Summary=$summary;Details=$details;Disks=$disks;SystemDrive=$systemDrive}
    } catch { return [PSCustomObject]@{Status='INFO';Summary='Storage information could not be retrieved';Details=@("Storage diagnostics were unavailable: $($_.Exception.Message)");Disks=@();SystemDrive=$systemDrive} }
}

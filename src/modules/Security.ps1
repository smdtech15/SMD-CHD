# ============================================================
# Security.ps1 - Microsoft Defender and Security Status Module
# ============================================================

function Get-SecurityHealth {
    $status = 'PASS'
    $details = @()
    $summary = 'Security protection appears active'

    try {
        # Try to get Microsoft Defender status
        $defender = Get-MpComputerStatus -ErrorAction SilentlyContinue
        
        if ($defender) {
            $avEnabled = $defender.AntivirusEnabled.ToString()
            $rtProtEnabled = $defender.RealTimeProtectionEnabled.ToString()
            $lastUpdate = $defender.AntivirusSignatureLastUpdated.ToString('yyyy-MM-dd HH:mm')
            
            $details += "Defender Enabled     : $avEnabled"
            $details += "Real-time Protection : $rtProtEnabled"
            $details += "Antivirus Signature  : $lastUpdate"

            if (-not $defender.AntivirusEnabled -or -not $defender.RealTimeProtectionEnabled) {
                $status = 'WARNING'
                $summary = 'Microsoft Defender real-time protection may be off'
            }
        } else {
            $details += 'Microsoft Defender  : Not available or different AV installed'
            $status = 'INFO'
            $summary = 'Could not query Microsoft Defender status'
        }
    } catch {
        $status = 'INFO'
        $summary = 'Security status could not be fully checked'
        $details += 'Note: Some security info requires administrator rights'
        $details += "Error: $($_.Exception.Message)"
    }

    return [PSCustomObject]@{
        Status = $status
        Summary = $summary
        Details = $details
    }
}

# ============================================================
# Network.ps1 - Network and Internet Connectivity Module
# ============================================================

function Get-NetworkHealth {
    $status = 'PASS'
    $details = @()
    $summary = 'Internet connection is working'

    try {
        # Get local IPv4 address
        $ip = (Get-NetIPAddress -AddressFamily IPv4 -ErrorAction SilentlyContinue | 
               Where-Object { $_.IPAddress -notlike '127.*' -and $_.PrefixOrigin -ne 'WellKnown' } | 
               Select-Object -First 1).IPAddress
        
        if ($ip) {
            $details += "Local IP       : $ip"
        } else {
            $details += 'Local IP       : Not available'
        }

        # Get default gateway
        $gw = (Get-NetRoute -DestinationPrefix '0.0.0.0/0' -ErrorAction SilentlyContinue | Select-Object -First 1).NextHop
        if ($gw) {
            $details += "Gateway        : $gw"
        } else {
            $details += 'Gateway        : Not available'
        }

        # Test internet connectivity
        $ping = Test-Connection -ComputerName 8.8.8.8 -Count 2 -Quiet -ErrorAction SilentlyContinue
        if ($ping) {
            $details += 'Internet       : Connected (PASS)'
        } else {
            $status = 'CRITICAL'
            $summary = 'No internet connectivity detected'
            $details += 'Internet       : NOT CONNECTED (FAIL)'
        }

        # Test DNS resolution
        try {
            $dns = Resolve-DnsName www.microsoft.com -ErrorAction Stop
            $details += 'DNS            : Working'
        } catch {
            if ($status -ne 'CRITICAL') {
                $status = 'WARNING'
            }
            $details += 'DNS            : Problem detected'
        }
    } catch {
        $status = 'WARNING'
        $summary = 'Could not fully test network'
        $details += "Error: $($_.Exception.Message)"
    }

    return [PSCustomObject]@{
        Status = $status
        Summary = $summary
        Details = $details
    }
}

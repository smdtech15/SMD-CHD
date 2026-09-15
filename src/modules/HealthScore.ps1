# ============================================================
# HealthScore.ps1 - Overall System Health Score Calculation
# ============================================================

function Get-HealthScore {
    param(
        [Parameter(Mandatory = $true)]
        $Results
    )

    $score = 100
    $recommendations = @()

    # Evaluate CPU status
    if ($Results.CPU.Status -eq 'CRITICAL') {
        $score -= 25
        $recommendations += 'CPU usage is critically high. Close unnecessary programs.'
    } elseif ($Results.CPU.Status -eq 'WARNING') {
        $score -= 12
        $recommendations += 'CPU usage is high. Consider closing heavy applications.'
    }

    # Evaluate RAM status
    if ($Results.RAM.Status -eq 'CRITICAL') {
        $score -= 25
        $recommendations += 'RAM is almost full. Close programs or consider adding more memory.'
    } elseif ($Results.RAM.Status -eq 'WARNING') {
        $score -= 12
        $recommendations += 'RAM usage is high. Close unused applications to free up memory.'
    }

    # Evaluate Storage status
    if ($Results.Storage.Status -eq 'CRITICAL') {
        $score -= 20
        $recommendations += 'One or more drives are almost full. Free up disk space immediately.'
    } elseif ($Results.Storage.Status -eq 'WARNING') {
        $score -= 10
        $recommendations += 'Storage is getting full. Clean up unnecessary files and programs.'
    }

    # Evaluate Network status
    if ($Results.Network.Status -eq 'CRITICAL') {
        $score -= 20
        $recommendations += 'No internet connection detected. Check network cable/Wi-Fi and router.'
    } elseif ($Results.Network.Status -eq 'WARNING') {
        $score -= 8
        $recommendations += 'Network issues detected. Check DNS settings or restart router.'
    }

    # Evaluate Security status
    if ($Results.Security.Status -eq 'WARNING') {
        $score -= 15
        $recommendations += 'Real-time protection may be disabled. Enable Microsoft Defender immediately.'
    }

    # Ensure score is within valid range
    if ($score -lt 0) {
        $score = 0
    }

    # Determine overall status
    $status = switch ($score) {
        { $_ -ge 90 } { 'Excellent' }
        { $_ -ge 75 } { 'Good' }
        { $_ -ge 50 } { 'Needs Attention' }
        default { 'Critical' }
    }

    return [PSCustomObject]@{
        Score = $score
        Status = $status
        Recommendations = $recommendations
    }
}

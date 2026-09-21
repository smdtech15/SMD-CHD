# ============================================================
# Recommendations.ps1 - Recommendations based only on diagnostics
# ============================================================
function Get-HealthRecommendations {
    param([Parameter(Mandatory=$true)]$Results)
    $items = @()
    $add = { param($key,$text) $items += [PSCustomObject]@{ Category=$key; Text=$text } }
    if ($Results.CPU -and $Results.CPU.Status -in @('WARNING','CRITICAL')) { & $add 'CPU' 'CPU usage is high. Close unnecessary applications and check background processes.' }
    if ($Results.RAM -and $Results.RAM.Status -in @('WARNING','CRITICAL')) { & $add 'RAM' 'RAM usage is high. Close unused applications or consider a memory upgrade.' }
    if ($Results.Storage -and $Results.Storage.Status -eq 'WARNING') { & $add 'Storage' 'Storage is getting full. Free unnecessary disk space.' }
    if ($Results.Storage -and $Results.Storage.Status -eq 'CRITICAL') { & $add 'Storage' 'Storage is critically full. Free disk space as soon as possible.' }
    if ($Results.GPU -and $Results.GPU.Status -in @('WARNING','CRITICAL')) { & $add 'GPU' 'Review GPU device status and graphics driver information.' }
    if ($Results.Battery -and $Results.Battery.Status -in @('WARNING','CRITICAL')) { & $add 'Battery' 'Battery capacity has decreased. Consider professional battery inspection.' }
    if ($Results.Network -and $Results.Network.Status -in @('WARNING','CRITICAL')) { & $add 'Network' 'Check network adapter, Wi-Fi/cable connection, DNS, or router.' }
    if ($Results.Security -and $Results.Security.Status -in @('WARNING','CRITICAL')) { & $add 'Security' 'Review Microsoft Defender and real-time protection status.' }
    if ($Results.Thermal -and $Results.Thermal.Status -in @('WARNING','CRITICAL')) { & $add 'Thermal' 'Thermal information indicates possible overheating. Check ventilation and cooling.' }
    return @($items)
}

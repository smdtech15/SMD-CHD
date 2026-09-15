# ============================================================
# Inventory.ps1 - Hardware and Software Inventory Module
# ============================================================

function Get-ComputerInventory {
    $inv = [ordered]@{}

    try {
        $cs = Get-CimInstance Win32_ComputerSystem
        $os = Get-CimInstance Win32_OperatingSystem
        $cpu = Get-CimInstance Win32_Processor | Select-Object -First 1

        $inv.ComputerName = $cs.Name
        $inv.WindowsVersion = $os.Caption
        $inv.Architecture = $os.OSArchitecture
        $inv.CPU = $cpu.Name
        $inv.RAM = "{0:N2} GB" -f ($cs.TotalPhysicalMemory / 1GB)

        $uptime = (Get-Date) - $os.LastBootUpTime
        $inv.Uptime = "{0} days, {1} hours" -f $uptime.Days, $uptime.Hours

        # Get network adapter information
        $adapter = Get-NetAdapter -ErrorAction SilentlyContinue | Where-Object Status -eq 'Up' | Select-Object -First 1
        $inv.NetworkAdapter = if ($adapter) { $adapter.Name } else { 'Not available' }

        # Get IPv4 address
        $ipAddr = (Get-NetIPAddress -AddressFamily IPv4 -ErrorAction SilentlyContinue | 
                   Where-Object { $_.IPAddress -notlike '127.*' } | 
                   Select-Object -First 1).IPAddress
        $inv.IPAddress = if ($ipAddr) { $ipAddr } else { 'Not available' }
    } catch {
        $inv.Error = $_.Exception.Message
    }

    return $inv
}

$MinRAM_GB = 2
$MinDisk_MB = 500

$OSArchitecture = (Get-CimInstance Win32_OperatingSystem).OSArchitecture
$TotalRAM_GB = [math]::Round((Get-CimInstance Win32_PhysicalMemory | Measure-Object -Property Capacity -Sum).Sum / 1GB)
$FreeDisk_MB = [math]::Round((Get-CimInstance Win32_LogicalDisk -Filter "DeviceID='C:'").FreeSpace / 1MB)

$PendingReboot = Test-Path "HKLM:\Software\Microsoft\Windows\CurrentVersion\Component Based Servicing\RebootPending"

if ($OSArchitecture -notlike "*64*") {
    Write-Host "Uyumsuz Mimari: Sadece x64 sistemler desteklenir."
    exit 1
}
elseif ($TotalRAM_GB -lt $MinRAM_GB -or $FreeDisk_MB -lt $MinDisk_MB) {
    Write-Host "Yetersiz Sistem Kaynagi (RAM veya Disk Alanı)."
    exit 1
}
elseif ($PendingReboot) {
    Write-Host "Kritik Hata: Sistemde bekleyen bir yeniden baslatma (Pending Reboot) var."
    exit 1
}
else {
    Write-Host "Sistem Uygun: Google Chrome Enterprise kurulumuna hazir."
    exit 0
}

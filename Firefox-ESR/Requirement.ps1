$FreeSpace = (Get-CimInstance Win32_LogicalDisk -Filter "DeviceID='C:'").FreeSpace
$DiskCheck = $FreeSpace -ge 209715200

$OS = Get-CimInstance Win32_OperatingSystem
$OSCheck = [version]$OS.Version -ge [version]"10.0.10240"

if ($DiskCheck -and $OSCheck) {
    Write-Output "Compliant"
    exit 0  # Sistem uygun, kuruluma gecilebilir.
}
else {
    Write-Output "Non-Compliant"
    exit 1  # HATA: Sistem gereksinimleri karsilamiyor, dagitimi durdur!
}

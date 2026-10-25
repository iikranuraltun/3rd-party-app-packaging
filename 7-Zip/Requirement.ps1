if ($env:PROCESSOR_ARCHITECTURE -ne "AMD64" -and $env:PROCESSOR_ARCHITEW6432 -ne "AMD64") {
    Write-Host "HATA: Bu paket yalnizca x64 (64-bit) mimarilerde calisabilir."
    exit 1
}

$FreeSpaceMB = [math]::Round(((Get-Volume -DriveLetter C).SizeRemaining / 1MB), 2)
if ($FreeSpaceMB -lt 20) {
    Write-Host "HATA: Yetersiz disk alanı. Mevcut: $FreeSpaceMB MB, Gereken: 20 MB"
    exit 1
}

Write-Host "UYGUN: Hedef sistem 7-Zip x64 kurulumu icin tum gereksinimleri karsilamaktadir."
exit 0

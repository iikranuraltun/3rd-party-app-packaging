$UninstallString = (Get-ItemProperty "HKLM:\Software\Wow6432Node\Microsoft\Windows\CurrentVersion\Uninstall\Mozilla Firefox*").UninstallString
$CleanPath = $UninstallString.Replace('"', '')

Start-Process -FilePath $CleanPath -ArgumentList "/S" -Wait
Start-Sleep -Seconds 10

$RegistryCheck = (Test-Path "HKLM:\Software\Wow6432Node\Microsoft\Windows\CurrentVersion\Uninstall\Mozilla Firefox*") -eq $false
$LogMessage = "[$(Get-Date)] Firefox Uninstallation completed. Registry check: $RegistryCheck"

if (-not (Test-Path ".\Logs")) { New-Item -ItemType Directory -Path ".\Logs" -Force | Out-Null }
$LogMessage | Out-File ".\Logs\Firefox_Uninstall.log" -Encoding utf8

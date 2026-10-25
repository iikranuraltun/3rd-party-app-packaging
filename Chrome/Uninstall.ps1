New-Item -ItemType Directory -Force -Path ".\Logs" | Out-Null

$Log = (Get-Item ".\").FullName + "\Logs\Chrome_Uninstall.log"
$ProductCode = (Get-ItemProperty "HKLM:\Software\Microsoft\Windows\CurrentVersion\Uninstall\*" |
    Where-Object { $_.DisplayName -like "Google Chrome*" }).PSChildName

if (-not $ProductCode)
{
    Write-Host "Google Chrome is not installed."
    exit 1605
}

$Process = Start-Process msiexec.exe -ArgumentList "/x $ProductCode /qn /norestart /L*v `"$Log`"" -Wait -PassThru

exit $Process.ExitCode

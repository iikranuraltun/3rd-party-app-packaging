New-Item -ItemType Directory -Force -Path ".\Logs" | Out-Null

$AppName = "7-Zip*"
$Log = (Get-Item ".\").FullName + "\Logs\7Zip_Uninstall.log"
$ProductCode = (Get-ItemProperty "HKLM:\Software\Microsoft\Windows\CurrentVersion\Uninstall\*" |
    Where-Object { $_.DisplayName -like $AppName }).PSChildName

if (-not $ProductCode)
{
    Write-Host "7-Zip is not installed."
    exit 1605
}

$Process = Start-Process msiexec.exe -ArgumentList "/x $ProductCode /qn /norestart /L*v `"$Log`"" -Wait -PassThru

exit $Process.ExitCode

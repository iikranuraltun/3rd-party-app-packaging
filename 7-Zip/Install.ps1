New-Item -ItemType Directory -Force -Path ".\Logs" | Out-Null

$Installer = (Get-Item ".\7z2602-x64.msi").FullName
$Log = (Get-Item ".\").FullName + "\Logs\7Zip_Install.log"

$Process = Start-Process msiexec.exe -ArgumentList "/i `"$Installer`" /qn /norestart /L*v `"$Log`"" -Wait -PassThru

if($Process.ExitCode -eq 0)
{
    Write-Host "Installation completed successfully."
}
else
{
    Write-Host "Installation failed."
}

exit $Process.ExitCode

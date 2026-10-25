New-Item -ItemType Directory -Force -Path ".\Logs" | Out-Null

$Installer = (Get-Item ".\Firefox Setup 140.12.0esr.exe").FullName
$Log = (Get-Item ".\").FullName + "\Logs\Firefox_Install.log"

$Process = Start-Process -FilePath $Installer -ArgumentList "-ms" -Wait -PassThru

Start-Sleep -Seconds 15

if($Process.ExitCode -eq 0)
{
    "[$(Get-Date)] Firefox Installation completed successfully. ExitCode: 0" | Out-File $Log -Encoding utf8
    Write-Host "Installation completed successfully."
}
else
{
    "[$(Get-Date)] Firefox Installation failed. ExitCode: $($Process.ExitCode)" | Out-File $Log -Encoding utf8
    Write-Host "Installation failed."
}

exit $Process.ExitCode

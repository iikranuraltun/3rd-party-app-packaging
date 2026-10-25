$Path = "C:\Program Files\7-Zip\7z.exe"

if (Test-Path -Path $Path -PathType Leaf)
{
    Write-Host "7-Zip is installed."
    exit 0
}
else
{
    Write-Host "7-Zip is NOT installed."
    exit 1
}

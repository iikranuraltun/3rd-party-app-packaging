$Path = "C:\Program Files (x86)\Mozilla Firefox\firefox.exe"

if (Test-Path -Path $Path -PathType Leaf)
{
    Write-Host "Mozilla Firefox is installed."
    exit 0
}
else
{
    Write-Host "Mozilla Firefox is NOT installed."
    exit 1
}

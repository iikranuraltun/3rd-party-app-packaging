$Path = "C:\Program Files\Google\Chrome\Application\chrome.exe"

if (Test-Path -Path $Path -PathType Leaf)
{
    Write-Host "Google Chrome is installed."
    exit 0
}
else
{
    Write-Host "Google Chrome is NOT installed."
    exit 1
}

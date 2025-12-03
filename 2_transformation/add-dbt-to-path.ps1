# PowerShell script to permanently add dbt to your PATH
# This adds C:\Users\FrederikHye-Hestvang\bin to your user PATH environment variable

$binPath = "C:\Users\FrederikHye-Hestvang\bin"

# Get current user PATH
$currentPath = [Environment]::GetEnvironmentVariable("Path", "User")

# Check if already in PATH
if ($currentPath -split ';' -contains $binPath) {
    Write-Host "dbt directory is already in your PATH!" -ForegroundColor Green
} else {
    # Add to PATH
    $newPath = "$currentPath;$binPath"
    [Environment]::SetEnvironmentVariable("Path", $newPath, "User")

    Write-Host "Successfully added dbt to your PATH!" -ForegroundColor Green
    Write-Host "IMPORTANT: You need to restart your PowerShell window for the changes to take effect." -ForegroundColor Yellow
    Write-Host "After restarting, you can use 'dbt run' from any directory." -ForegroundColor Cyan
}

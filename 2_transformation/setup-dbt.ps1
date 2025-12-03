# Add current directory to PATH for this PowerShell session
$env:Path = "$PWD;$env:Path"
Write-Host "dbt command is now available. You can use 'dbt run', 'dbt test', etc." -ForegroundColor Green

Get-ChildItem "$PSScriptRoot\schema\*.sql" | Sort-Object Name | ForEach-Object {
    Write-Host "Applying $($_.Name)..."
    Get-Content $_.FullName | docker compose exec -T postgres psql -U plutos -d plutos -f -
}
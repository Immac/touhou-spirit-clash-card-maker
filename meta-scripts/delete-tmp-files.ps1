$directory = Get-Location
$confirmation = Read-Host "Are you sure you want to delete all .tmp files from $directory? (yes/no)"

if ($confirmation -eq "yes") {
    Get-ChildItem -Path $directory -Filter *.tmp -Recurse | ForEach-Object {
        Write-Host "Deleting file $($_.FullName)" -ForegroundColor Red
        Remove-Item $_.FullName
    }
} else {
    Write-Host "Operation cancelled." -ForegroundColor Yellow
}
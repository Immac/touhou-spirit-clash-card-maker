$rootPath = Resolve-Path .\
Get-ChildItem -Path .\ -Include *.tres -Recurse | ForEach-Object {
    $content = Get-Content $_.FullName -Raw
    $updatedContent = $content -replace '(key = &"\$[^"]*[^$])"', '$1$"'
    $relativePath = $_.FullName.Replace($rootPath, '')

    if ($content -eq $updatedContent) {
        Write-Host "File $relativePath was not changed." -ForegroundColor Green
    } else {
        Set-Content -Path $_.FullName -Value $updatedContent
        Write-Host "File $relativePath was changed." -ForegroundColor Red
    }
}
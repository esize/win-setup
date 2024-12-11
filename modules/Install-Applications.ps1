function Install-Applications {
    [CmdletBinding()]
    param()

    $appsConfig = Get-Content "$scriptPath\config\apps.json" | ConvertFrom-Json

    foreach ($app in $appsConfig.winget) {
        Write-Log "Installing $($app.name)..."
        try {
            winget install -e --id $app.id --accept-source-agreements --accept-package-agreements -h
        }
        catch {
            Write-Log "Failed to install $($app.name): $_" -Level Warning
        }
    }
} 
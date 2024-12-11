function Install-Applications {
    [CmdletBinding()]
    param()

    $appsConfig = Get-Content "$scriptPath\config\apps.json" | ConvertFrom-Json
    $totalApps = $appsConfig.winget.Count
    $currentApp = 0

    foreach ($app in $appsConfig.winget) {
        $currentApp++
        $progressPercentage = [math]::Round(($currentApp / $totalApps) * 100)
        
        # Clear the previous line
        Write-Host "`r" -NoNewline
        
        # Create progress bar
        $progressBar = "[" + ("=" * [math]::Floor($progressPercentage / 2)) + (" " * (50 - [math]::Floor($progressPercentage / 2))) + "]"
        
        # Display current progress
        Write-Host "`rInstalling $($app.name) $progressBar [$currentApp/$totalApps]" -NoNewline
        
        try {
            # Redirect winget output to null to keep display clean
            winget install -e --id $app.id --accept-source-agreements --accept-package-agreements -h | Out-Null
        }
        catch {
            Write-Log "Failed to install $($app.name): $_" -Level Warning
        }
    }
    
    # Add a newline at the end
    Write-Host "`nAll applications installed!"
} 
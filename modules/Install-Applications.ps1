function Install-Application {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $true)]
        [string]$appId
    )

    try {
        # Check if the application is already installed
        $installed = winget list --id $appId --accept-source-agreements 2>$null
        if ($installed -match $appId) {
            Write-VerboseLog "$appId is already installed, skipping..."
            return
        }

        # Install the application if not already installed
        winget install -e --id $appId --accept-source-agreements --accept-package-agreements -h | Out-Null
    }
    catch {
        Write-WarningLog "Failed to install $appId : $_"
    }
}

function Install-Applications {
    [CmdletBinding()]
    param()

    $appsConfig = Get-Content "$scriptPath\config\apps.json" | ConvertFrom-Json
    $totalApps = $appsConfig.winget.Count
    $currentApp = 0

    foreach ($app in $appsConfig.winget) {
        $currentApp++
        Write-ProgressBar -Current $currentApp -Total $totalApps -Message "Installing $($app.name)"
        Install-Application -appId $app.id
    }
    
    Write-InfoLog "All applications installed!"
} 
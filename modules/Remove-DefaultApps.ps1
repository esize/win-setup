function Remove-DefaultApps {
    [CmdletBinding()]
    param()

    # First handle Copilot separately using winget
    try {
        Write-Log -Level DEBUG "Attempting to remove Copilot using winget..."
        winget uninstall Copilot --silent --accept-source-agreements | Out-Null
        Write-Log -Level DEBUG "Successfully removed Copilot"
    }
    catch {
        Write-Log -Level WARN "Failed to remove Copilot using winget: $_"
    }

    $appsToRemove = @(
        "Microsoft.WindowsFeedbackHub",
        "Microsoft.XboxGamingOverlay",
        "Microsoft.GetHelp",
        "Microsoft.Getstarted",
        "Microsoft.MicrosoftOfficeHub",
        "Microsoft.ScreenSketch",
        "Microsoft.Clipchamp",
        "Microsoft.BingNews",
        "MicrosoftTeams",
        "Microsoft.ToDo",
        "Microsoft.OutlookForWindows",
        "Microsoft.YourPhone",
        "Microsoft.QuickAssist",
        "Microsoft.MicrosoftSolitaireCollection",
        "Microsoft.WindowsSoundRecorder",
        "Microsoft.MicrosoftStickyNotes",
        "Microsoft.BingWeather",
        "Microsoft.GamingApp",
        "Microsoft.Xbox.TCUI",
        "Microsoft.XboxGameOverlay",
        "Microsoft.XboxIdentityProvider",
        "Microsoft.XboxSpeechToTextOverlay"
    )

    foreach ($app in $appsToRemove) {
        try {
            $appExists = Get-AppxPackage -Name $app -AllUsers -ErrorAction SilentlyContinue
            if ($appExists) {
                
                # Stop related processes first
                if ($app -eq "Microsoft.OutlookForWindows") {
                    Get-Process | Where-Object { $_.Name -like "*outlook*" } | Stop-Process -Force -ErrorAction SilentlyContinue
                    Start-Sleep -Seconds 2
                }

                # Try to remove provisioned package first
                [void](Get-AppxProvisionedPackage -Online | Where-Object { $_.DisplayName -eq $app } | 
                    Remove-AppxProvisionedPackage -Online -ErrorAction SilentlyContinue)

                # Remove the package for all users
                Get-AppxPackage -Name $app -AllUsers | Remove-AppxPackage -AllUsers -ErrorAction Stop | Out-Null
                Write-Log -Level DEBUG "Successfully removed $app"
            } else {
                Write-Log -Level DEBUG "$app not found, skipping..."
            }
        }
        catch {
            Write-Log -Level WARN "Failed to remove $app : $_"
            
            # Additional cleanup attempt for Outlook
            if ($app -eq "Microsoft.OutlookForWindows") {
                try {
                    # Force remove using DISM
                    $packageFullName = (Get-AppxPackage -Name $app -AllUsers).PackageFullName
                    if ($packageFullName) {
                        DISM.exe /Online /Remove-ProvisionedAppxPackage /PackageName:$packageFullName
                    }
                }
                catch {
                    Write-Log -Level WARN "Failed additional cleanup for Outlook: $_"
                }
            }
        }
    }
} 
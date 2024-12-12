function Remove-DefaultApps {
    [CmdletBinding()]
    param()

    # Define apps to remove with their winget package names
    $appsToRemove = @(
        "Copilot",
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
            Write-Log -Level DEBUG "Attempting to remove $app using winget..."
            winget uninstall $app --silent --accept-source-agreements | Out-Null
            Write-Log -Level DEBUG "Successfully removed $app"
        }
        catch {
            Write-Log -Level WARN "Failed to remove $app using winget: $_"
        }
    }
} 
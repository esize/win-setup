function Remove-DefaultApps {
    [CmdletBinding()]
    param()

    # Define apps to remove with their winget package names
    $appsToRemove = @(
        "Microsoft.WindowsFeedbackHub_8wekyb3d8bbwe",
        "Microsoft.XboxGamingOverlay_8wekyb3d8bbwe",
        "Microsoft.GetHelp_8wekyb3d8bbwe",
        "Microsoft.Getstarted_8wekyb3d8bbwe",
        "Microsoft.MicrosoftOfficeHub_8wekyb3d8bbwe",
        "Microsoft.ScreenSketch_8wekyb3d8bbwe",
        "Microsoft.Clipchamp_8wekyb3d8bbwe",
        "Microsoft.BingNews_8wekyb3d8bbwe",
        "MicrosoftTeams_8wekyb3d8bbwe",
        "Microsoft.ToDo_8wekyb3d8bbwe",
        "Microsoft.OutlookForWindows_8wekyb3d8bbwe",
        "Microsoft.YourPhone_8wekyb3d8bbwe",
        "Microsoft.QuickAssist_8wekyb3d8bbwe",
        "Microsoft.MicrosoftSolitaireCollection_8wekyb3d8bbwe",
        "Microsoft.WindowsSoundRecorder_8wekyb3d8bbwe",
        "Microsoft.MicrosoftStickyNotes_8wekyb3d8bbwe",
        "Microsoft.BingWeather_8wekyb3d8bbwe",
        "Microsoft.GamingApp_8wekyb3d8bbwe",
        "Microsoft.Xbox.TCUI_8wekyb3d8bbwe",
        "Microsoft.XboxGameOverlay_8wekyb3d8bbwe",
        "Microsoft.XboxIdentityProvider_8wekyb3d8bbwe",
        "Microsoft.XboxSpeechToTextOverlay_8wekyb3d8bbwe"
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
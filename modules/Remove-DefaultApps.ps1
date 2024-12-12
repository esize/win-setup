function Remove-DefaultApps {
    [CmdletBinding()]
    param()

    Write-Log "Removing default Windows applications..."
    
    $appsToRemove = @(
        "Microsoft.Windows.Copilot",
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
                Get-AppxPackage -Name $app -AllUsers | Remove-AppxPackage -ErrorAction Stop
                Write-Log "Successfully removed $app" -Level Information
            } else {
                Write-Log "$app not found, skipping..." -Level Information
            }
        }
        catch {
            Write-Log "Failed to remove $app : $_" -Level Warning
        }
    }
} 
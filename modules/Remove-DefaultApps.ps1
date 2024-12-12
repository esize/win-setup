function Remove-DefaultApps {
    [CmdletBinding()]
    param()

    Write-InfoLog "Removing default Windows applications..."
    
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
                Write-InfoLog "Successfully removed $app"
            } else {
                Write-VerboseLog "$app not found, skipping..."
            }
        }
        catch {
            Write-WarningLog "Failed to remove $app : $_"
        }
    }
} 
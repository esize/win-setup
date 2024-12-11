function Remove-DefaultApps {
    [CmdletBinding()]
    param()

    Write-Log "Removing default Windows applications..."

    $appsToRemove = @(
        "Microsoft.Windows.Copilot"
        "Microsoft.WindowsFeedbackHub"
        "Microsoft.XboxGamingOverlay"
        "Microsoft.GetHelp"
        "Microsoft.Getstarted"
        "Microsoft.MicrosoftOfficeHub"
        "Microsoft.ScreenSketch"
        "Microsoft.Clipchamp"
        "Microsoft.BingNews"
        "MicrosoftTeams"
        "Microsoft.ToDo"
        "Microsoft.OutlookForWindows"
        "Microsoft.YourPhone"
        "Microsoft.QuickAssist"
        "Microsoft.MicrosoftSolitaireCollection"
        "Microsoft.WindowsSoundRecorder"
        "Microsoft.MicrosoftStickyNotes"
        "Microsoft.BingWeather"
        "Microsoft.GamingApp"
        "Microsoft.Xbox.TCUI"
        "Microsoft.XboxGameOverlay"
        "Microsoft.XboxIdentityProvider"
        "Microsoft.XboxSpeechToTextOverlay"
    )

    foreach ($app in $appsToRemove) {
        try {
            Write-Log "Removing $app..."
            Get-AppxPackage -Name $app -AllUsers | Remove-AppxPackage -ErrorAction SilentlyContinue
            Get-AppxProvisionedPackage -Online | Where-Object DisplayName -eq $app | Remove-AppxProvisionedPackage -Online -ErrorAction SilentlyContinue
        }
        catch {
            Write-Log "Failed to remove $app: $_" -Level Warning
        }
    }

    Write-Log "Default apps removal completed!"
} 
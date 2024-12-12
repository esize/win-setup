function Remove-DefaultApps {
    [CmdletBinding()]
    param()

    Write-Host "`n🧹 Removing default Windows applications..." -ForegroundColor Cyan
    
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

    $totalApps = $appsToRemove.Count
    $currentApp = 0
    $removed = 0
    $failed = 0

    foreach ($app in $appsToRemove) {
        $currentApp++
        $percentComplete = [math]::Round(($currentApp / $totalApps) * 100)
        
        Write-Progress -Activity "Removing Default Apps" -Status "$app ($currentApp of $totalApps)" `
            -PercentComplete $percentComplete

        try {
            $appExists = Get-AppxPackage -Name $app -AllUsers -ErrorAction SilentlyContinue
            if ($appExists) {
                Get-AppxPackage -Name $app -AllUsers | Remove-AppxPackage -ErrorAction Stop
                Get-AppxProvisionedPackage -Online | Where-Object DisplayName -eq $app | 
                    Remove-AppxProvisionedPackage -Online -ErrorAction Stop
                $removed++
                Write-Host "  ✓ Removed $app" -ForegroundColor Green
            } else {
                Write-Host "  • Skipped $app (not installed)" -ForegroundColor Gray
            }
        }
        catch {
            $failed++
            Write-Host "  ✗ Failed to remove $app" -ForegroundColor Red
        }
    }

    Write-Progress -Activity "Removing Default Apps" -Completed
    Write-Host "`n📊 Summary:" -ForegroundColor Cyan
    Write-Host "  ✓ Successfully removed: $removed" -ForegroundColor Green
    if ($failed -gt 0) {
        Write-Host "  ✗ Failed to remove: $failed" -ForegroundColor Red
    }
    Write-Host ""
} 
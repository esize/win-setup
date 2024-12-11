function Set-StartMenuPreferences {
    [CmdletBinding()]
    param()

    $settings = Get-Content "$scriptPath\config\settings.json" | ConvertFrom-Json

    Write-Log "Configuring Start Menu preferences..."

    # Show recently added apps
    Set-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced" -Name "Start_TrackProgs" -Value 1

    # Disable show most used apps
    Set-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced" -Name "Start_TrackDocs" -Value 0

    # Show recently opened items
    Set-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced" -Name "Start_TrackDocs" -Value 1

    # Disable recommendations
    Set-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced" -Name "Start_ShowRecommendations" -Value 0

    # Disable account notifications
    Set-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced" -Name "Start_AccountNotifications" -Value 0

    # Disable Bing search in Start menu
    if ($settings.system.disableBingSearch) {
        Write-Log "Disabling Bing search in Start menu..."
        Set-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Search" -Name "BingSearchEnabled" -Value 0
        Set-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Search" -Name "CortanaConsent" -Value 0
    }
} 
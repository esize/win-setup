function Set-StartMenuPreferences {
    [CmdletBinding()]
    param()

    Write-Log -Level INFO "Configuring Start Menu preferences..."

    # Show recently added apps
    Write-Log -Level DEBUG "Showing recently added apps..."
    Set-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced" -Name "Start_TrackProgs" -Value 1

    # Disable show most used apps
    Write-Log -Level DEBUG "Disabling show most used apps..."
    Set-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced" -Name "Start_TrackDocs" -Value 0

    # Show recently opened items
    Write-Log -Level DEBUG "Showing recently opened items..."
    Set-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced" -Name "Start_TrackDocs" -Value 1

    # Disable recommendations
    Write-Log -Level DEBUG "Disabling recommendations..."
    Set-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced" -Name "Start_ShowRecommendations" -Value 0

    # Disable account notifications
    Write-Log -Level DEBUG "Disabling account notifications..."
    Set-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced" -Name "Start_AccountNotifications" -Value 0

    # Disable Bing search in Start menu
    Write-Log -Level DEBUG "Disabling Bing search in Start menu..."
    Set-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Search" -Name "BingSearchEnabled" -Value 0
    Set-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Search" -Name "CortanaConsent" -Value 0


    Write-Log -Level INFO "Start Menu preferences configured successfully!"
} 
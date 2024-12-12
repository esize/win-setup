function Set-StartMenuPreferences {
    [CmdletBinding()]
    param()

    Write-InfoLog "Configuring Start Menu preferences..."

    # Show recently added apps
    Write-VerboseLog "Showing recently added apps..."
    Set-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced" -Name "Start_TrackProgs" -Value 1

    # Disable show most used apps
    Write-VerboseLog "Disabling show most used apps..."
    Set-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced" -Name "Start_TrackDocs" -Value 0

    # Show recently opened items
    Write-VerboseLog "Showing recently opened items..."
    Set-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced" -Name "Start_TrackDocs" -Value 1

    # Disable recommendations
    Write-VerboseLog "Disabling recommendations..."
    Set-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced" -Name "Start_ShowRecommendations" -Value 0

    # Disable account notifications
    Write-VerboseLog "Disabling account notifications..."
    Set-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced" -Name "Start_AccountNotifications" -Value 0

    # Disable Bing search in Start menu
    Write-VerboseLog "Disabling Bing search in Start menu..."
    Set-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Search" -Name "BingSearchEnabled" -Value 0
    Set-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Search" -Name "CortanaConsent" -Value 0


    Write-InfoLog "Start Menu preferences configured successfully!"
} 
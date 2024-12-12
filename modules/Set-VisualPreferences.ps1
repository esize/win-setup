function Set-VisualPreferences {
    [CmdletBinding()]
    param()

    Write-Log -Level INFO "Configuring visual preferences..."

    try {
        # Enable transparency effects
        Set-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Themes\Personalize" -Name "EnableTransparency" -Value 1

        # Configure snap window features
        Set-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced" -Name "EnableSnapAssistFlyout" -Value 1
        Set-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced" -Name "SnapAssist" -Value 1
        
        # Disable mouse acceleration
        Set-ItemProperty -Path "HKCU:\Control Panel\Mouse" -Name "MouseSpeed" -Value "0"
        Set-ItemProperty -Path "HKCU:\Control Panel\Mouse" -Name "MouseThreshold1" -Value "0"
        Set-ItemProperty -Path "HKCU:\Control Panel\Mouse" -Name "MouseThreshold2" -Value "0"

        Write-Log -Level INFO "Visual preferences configured successfully!"
    }
    catch {
        Write-Log -Level ERROR "Failed to configure visual preferences: $_"
    }
} 
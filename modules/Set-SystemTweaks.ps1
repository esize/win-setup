function Set-SystemTweaks {
    [CmdletBinding()]
    param()

    $settings = Get-Content "$scriptPath\config\settings.json" | ConvertFrom-Json

    # Disable Consumer Features
    if ($settings.system.disableConsumerFeatures) {
        Set-ItemProperty -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\CloudContent" -Name "DisableWindowsConsumerFeatures" -Value 1
    }

    # Disable Activity History
    if ($settings.system.disableActivityHistory) {
        Set-ItemProperty -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\System" -Name "EnableActivityFeed" -Value 0
        Set-ItemProperty -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\System" -Name "PublishUserActivities" -Value 0
    }

    # Disable GameDVR
    if ($settings.system.disableGameDVR) {
        Set-ItemProperty -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\GameDVR" -Name "AllowGameDVR" -Value 0
    }

    # Disable Hibernation
    if ($settings.system.disableHibernation) {
        powercfg /hibernate off
    }

    # Disable Homegroup
    if ($settings.system.disableHomegroup) {
        Stop-Service "HomeGroupProvider" -Force
        Set-Service "HomeGroupProvider" -StartupType Disabled
    }

    # Disable Wifi-Sense
    if ($settings.system.disableWifiSense) {
        Set-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\PolicyManager\default\WiFi\AllowWiFiHotSpotReporting" -Name "Value" -Value 0
        Set-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\PolicyManager\default\WiFi\AllowAutoConnectToWiFiSenseHotspots" -Name "Value" -Value 0
    }

    # Disable Adobe Telemetry
    if ($settings.system.disableAdobeTelemetry) {
        Stop-Service "AdobeARMservice" -Force
        Set-Service "AdobeARMservice" -StartupType Disabled
        Get-ScheduledTask "Adobe Acrobat Update Task" -ErrorAction SilentlyContinue | Disable-ScheduledTask
    }

    # Disable Microsoft Copilot
    if ($settings.system.disableCopilot) {
        Set-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced" -Name "ShowCopilotButton" -Value 0
    }

    # Set Time to UTC
    if ($settings.system.setUTCTime) {
        Set-ItemProperty -Path "HKLM:\SYSTEM\CurrentControlSet\Control\TimeZoneInformation" -Name "RealTimeIsUniversal" -Value 1
    }

    # NumLock on Startup
    if ($settings.system.enableNumLockOnStart) {
        Set-ItemProperty -Path "HKU:\.DEFAULT\Control Panel\Keyboard" -Name "InitialKeyboardIndicators" -Value 2
    }

    # Mouse Acceleration
    if (-not $settings.visual.mouseAcceleration) {
        Set-ItemProperty -Path "HKCU:\Control Panel\Mouse" -Name "MouseSpeed" -Value 0
        Set-ItemProperty -Path "HKCU:\Control Panel\Mouse" -Name "MouseThreshold1" -Value 0
        Set-ItemProperty -Path "HKCU:\Control Panel\Mouse" -Name "MouseThreshold2" -Value 0
    }

    # Snap Settings
    if ($settings.visual.snapWindow) {
        Set-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced" -Name "SnapEnabled" -Value 1
    }

    if ($settings.visual.snapAssistFlyout) {
        Set-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced" -Name "SnapAssist" -Value 1
    }

    if ($settings.visual.snapAssistSuggestions) {
        Set-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced" -Name "SnapAssistFlyout" -Value 1
    }
} 
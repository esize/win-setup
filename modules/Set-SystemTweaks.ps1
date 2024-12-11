function Set-SystemTweaks {
    [CmdletBinding()]
    param()

    $settings = Get-Content "$scriptPath\config\settings.json" | ConvertFrom-Json

    # Helper function to ensure registry path exists
    function Ensure-RegistryPath {
        param([string]$Path)
        if (-not (Test-Path $Path)) {
            New-Item -Path $Path -Force | Out-Null
        }
    }

    # Disable Consumer Features
    if ($settings.system.disableConsumerFeatures) {
        $path = "HKLM:\SOFTWARE\Policies\Microsoft\Windows\CloudContent"
        Ensure-RegistryPath -Path $path
        Set-ItemProperty -Path $path -Name "DisableWindowsConsumerFeatures" -Value 1
    }

    # Disable Activity History
    if ($settings.system.disableActivityHistory) {
        $path = "HKLM:\SOFTWARE\Policies\Microsoft\Windows\System"
        Ensure-RegistryPath -Path $path
        Set-ItemProperty -Path $path -Name "EnableActivityFeed" -Value 0
        Set-ItemProperty -Path $path -Name "PublishUserActivities" -Value 0
    }

    # Disable GameDVR
    if ($settings.system.disableGameDVR) {
        $path = "HKLM:\SOFTWARE\Policies\Microsoft\Windows\GameDVR"
        Ensure-RegistryPath -Path $path
        Set-ItemProperty -Path $path -Name "AllowGameDVR" -Value 0
    }

    # Disable Hibernation
    if ($settings.system.disableHibernation) {
        powercfg /hibernate off
    }

    # Disable Homegroup (with error handling)
    if ($settings.system.disableHomegroup) {
        $service = Get-Service -Name "HomeGroupProvider" -ErrorAction SilentlyContinue
        if ($service) {
            Stop-Service "HomeGroupProvider" -Force -ErrorAction SilentlyContinue
            Set-Service "HomeGroupProvider" -StartupType Disabled -ErrorAction SilentlyContinue
        }
    }

    # Disable Wifi-Sense
    if ($settings.system.disableWifiSense) {
        $path1 = "HKLM:\SOFTWARE\Microsoft\PolicyManager\default\WiFi\AllowWiFiHotSpotReporting"
        $path2 = "HKLM:\SOFTWARE\Microsoft\PolicyManager\default\WiFi\AllowAutoConnectToWiFiSenseHotspots"
        
        Ensure-RegistryPath -Path $path1
        Ensure-RegistryPath -Path $path2
        
        Set-ItemProperty -Path $path1 -Name "Value" -Value 0
        Set-ItemProperty -Path $path2 -Name "Value" -Value 0
    }

    # Disable Adobe Telemetry (with error handling)
    if ($settings.system.disableAdobeTelemetry) {
        $service = Get-Service -Name "AdobeARMservice" -ErrorAction SilentlyContinue
        if ($service) {
            Stop-Service "AdobeARMservice" -Force -ErrorAction SilentlyContinue
            Set-Service "AdobeARMservice" -StartupType Disabled -ErrorAction SilentlyContinue
        }
        
        $task = Get-ScheduledTask "Adobe Acrobat Update Task" -ErrorAction SilentlyContinue
        if ($task) {
            Disable-ScheduledTask -TaskName "Adobe Acrobat Update Task" -ErrorAction SilentlyContinue
        }
    }

    # Disable Microsoft Copilot
    if ($settings.system.disableCopilot) {
        Set-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced" -Name "ShowCopilotButton" -Value 0
    }

    # Set Time to UTC
    if ($settings.system.setUTCTime) {
        Set-ItemProperty -Path "HKLM:\SYSTEM\CurrentControlSet\Control\TimeZoneInformation" -Name "RealTimeIsUniversal" -Value 1
    }

    # NumLock on Startup (with proper registry handling)
    if ($settings.system.enableNumLockOnStart) {
        # Load the default user registry hive
        $defaultUserPath = "HKU:\DEFAULT"
        if (-not (Test-Path $defaultUserPath)) {
            reg load "HKU\DEFAULT" "C:\Users\Default\NTUSER.DAT"
        }

        try {
            # Set for Default User
            $path = "HKU:\DEFAULT\Control Panel\Keyboard"
            Ensure-RegistryPath -Path $path
            Set-ItemProperty -Path $path -Name "InitialKeyboardIndicators" -Value 2

            # Set for Current User
            $path = "HKCU:\Control Panel\Keyboard"
            Ensure-RegistryPath -Path $path
            Set-ItemProperty -Path $path -Name "InitialKeyboardIndicators" -Value 2
        }
        finally {
            # Unload the default user hive
            [gc]::Collect()
            reg unload "HKU\DEFAULT"
        }
    } else {
        # Set for Default User
        Set-ItemProperty -Path "HKU:\.DEFAULT\Control Panel\Keyboard" -Name "InitialKeyboardIndicators" -Value 0
        # Set for Current User
        Set-ItemProperty -Path "HKCU:\Control Panel\Keyboard" -Name "InitialKeyboardIndicators" -Value 0
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
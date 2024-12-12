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
        try {
            # Set for Current User
            $path = "HKCU:\Control Panel\Keyboard"
            if (-not (Test-Path $path)) {
                New-Item -Path $path -Force | Out-Null
            }
            Set-ItemProperty -Path $path -Name "InitialKeyboardIndicators" -Value "2"

            # Set for Default User
            $defaultUserPath = "C:\Users\Default\NTUSER.DAT"
            if (Test-Path $defaultUserPath) {
                # Load the default user registry hive
                reg load "HKU\DefaultUser" $defaultUserPath | Out-Null

                # Set the registry value
                $defaultPath = "Registry::HKU\DefaultUser\Control Panel\Keyboard"
                if (-not (Test-Path $defaultPath)) {
                    New-Item -Path $defaultPath -Force | Out-Null
                }
                Set-ItemProperty -Path $defaultPath -Name "InitialKeyboardIndicators" -Value "2"

                # Force garbage collection and unload the hive
                [gc]::Collect()
                reg unload "HKU\DefaultUser" | Out-Null
            }
        }
        catch {
            Write-Log "Failed to set NumLock settings: $_" -Level Warning
        }
    } else {
        try {
            # Set for Current User only
            $path = "HKCU:\Control Panel\Keyboard"
            if (-not (Test-Path $path)) {
                New-Item -Path $path -Force | Out-Null
            }
            Set-ItemProperty -Path $path -Name "InitialKeyboardIndicators" -Value "0"
        }
        catch {
            Write-Log "Failed to set NumLock settings: $_" -Level Warning
        }
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
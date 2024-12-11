function Set-DeveloperPreferences {
    [CmdletBinding()]
    param()

    $settings = Get-Content "$scriptPath\config\settings.json" | ConvertFrom-Json

    # Enable/Disable Developer Mode
    $developerModePath = "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\AppModelUnlock"
    if ($settings.developer.developerMode) {
        if (-not (Test-Path $developerModePath)) {
            New-Item -Path $developerModePath -Force | Out-Null
        }
        Set-ItemProperty -Path $developerModePath -Name "AllowDevelopmentWithoutDevLicense" -Value 1
    } else {
        if (Test-Path $developerModePath) {
            Set-ItemProperty -Path $developerModePath -Name "AllowDevelopmentWithoutDevLicense" -Value 0
        }
    }

    # Configure Device Portal
    $devicePortalPath = "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\WebManagement\Service"
    if ($settings.developer.devicePortal) {
        if (-not (Test-Path $devicePortalPath)) {
            New-Item -Path $devicePortalPath -Force | Out-Null
        }
        Set-ItemProperty -Path $devicePortalPath -Name "EnableDevicePortal" -Value 1
    } else {
        if (Test-Path $devicePortalPath) {
            Set-ItemProperty -Path $devicePortalPath -Name "EnableDevicePortal" -Value 0
        }
    }

    # Configure Device Discovery
    $deviceDiscoveryPath = "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\DeviceAccess\Global\LooselyCoupled"
    if ($settings.developer.deviceDiscovery) {
        if (-not (Test-Path $deviceDiscoveryPath)) {
            New-Item -Path $deviceDiscoveryPath -Force | Out-Null
        }
        Set-ItemProperty -Path $deviceDiscoveryPath -Name "Value" -Value "Allow"
    } else {
        if (Test-Path $deviceDiscoveryPath) {
            Set-ItemProperty -Path $deviceDiscoveryPath -Name "Value" -Value "Deny"
        }
    }

    # Enable/Disable End Task in Taskbar
    $endTaskPath = "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced"
    if ($settings.developer.enableEndTask) {
        Set-ItemProperty -Path $endTaskPath -Name "TaskbarEndTask" -Value 1
    } else {
        Set-ItemProperty -Path $endTaskPath -Name "TaskbarEndTask" -Value 0
    }

    # Set Default Terminal
    $defaultTerminalPath = "HKCU:\Console\%%Startup"
    if ($settings.developer.defaultTerminal -eq "Windows Terminal") {
        Set-ItemProperty -Path $defaultTerminalPath -Name "DelegationConsole" -Value "{2EACA947-7F5F-4CFA-BA87-8F7FBEEFBE69}"
        Set-ItemProperty -Path $defaultTerminalPath -Name "DelegationTerminal" -Value "{E12CFF52-A866-4C77-9A90-F570A7AA2C6B}"
    }
} 
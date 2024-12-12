function Set-DeveloperPreferences {
    [CmdletBinding()]
    param()

    Write-Log "Configuring developer preferences..."

    # Enable Developer Mode
    $developerModePath = "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\AppModelUnlock"
    if (-not (Test-Path $developerModePath)) {
        New-Item -Path $developerModePath -Force | Out-Null
    }
    Set-ItemProperty -Path $developerModePath -Name "AllowDevelopmentWithoutDevLicense" -Value 1

    # Disable Device Portal
    $devicePortalPath = "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\WebManagement\Service"
    if (Test-Path $devicePortalPath) {
        Set-ItemProperty -Path $devicePortalPath -Name "EnableDevicePortal" -Value 0
    }

    # Disable Device Discovery
    $deviceDiscoveryPath = "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\DeviceAccess\Global\LooselyCoupled"
    if (Test-Path $deviceDiscoveryPath) {
        Set-ItemProperty -Path $deviceDiscoveryPath -Name "Value" -Value "Deny"
    }

    # Enable End Task in Taskbar
    Set-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced" -Name "TaskbarEndTask" -Value 1

    # Set Windows Terminal as Default
    $defaultTerminalPath = "HKCU:\Console\%%Startup"
    Set-ItemProperty -Path $defaultTerminalPath -Name "DelegationConsole" -Value "{2EACA947-7F5F-4CFA-BA87-8F7FBEEFBE69}"
    Set-ItemProperty -Path $defaultTerminalPath -Name "DelegationTerminal" -Value "{E12CFF52-A866-4C77-9A90-F570A7AA2C6B}"
} 
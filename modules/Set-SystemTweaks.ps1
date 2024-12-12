function Set-SystemTweaks {
    [CmdletBinding()]
    param()

    # Helper function to ensure registry path exists
    function Ensure-RegistryPath {
        param([string]$Path)
        if (-not (Test-Path $Path)) {
            New-Item -Path $Path -Force | Out-Null
        }
    }

    # Disable Consumer Features
    $path = "HKLM:\SOFTWARE\Policies\Microsoft\Windows\CloudContent"
    Ensure-RegistryPath -Path $path
    Set-ItemProperty -Path $path -Name "DisableWindowsConsumerFeatures" -Value 1

    # Disable Activity History
    $path = "HKLM:\SOFTWARE\Policies\Microsoft\Windows\System"
    Ensure-RegistryPath -Path $path
    Set-ItemProperty -Path $path -Name "EnableActivityFeed" -Value 0
    Set-ItemProperty -Path $path -Name "PublishUserActivities" -Value 0

    # Disable GameDVR
    $path = "HKLM:\SOFTWARE\Policies\Microsoft\Windows\GameDVR"
    Ensure-RegistryPath -Path $path
    Set-ItemProperty -Path $path -Name "AllowGameDVR" -Value 0

    # Disable Hibernation
    powercfg /hibernate off

    # Disable Homegroup
    $service = Get-Service -Name "HomeGroupProvider" -ErrorAction SilentlyContinue
    if ($service) {
        Stop-Service "HomeGroupProvider" -Force -ErrorAction SilentlyContinue
        Set-Service "HomeGroupProvider" -StartupType Disabled -ErrorAction SilentlyContinue
    }

} 
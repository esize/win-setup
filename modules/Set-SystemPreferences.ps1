function Set-SystemPreferences {
    [CmdletBinding()]
    param()

    Write-Log "Configuring system preferences..."

    # Show file extensions
    Set-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced" -Name "HideFileExt" -Value 0

    # Show hidden files
    Set-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced" -Name "Hidden" -Value 1

    # Disable Cortana
    $cortanaPath = "HKLM:\SOFTWARE\Policies\Microsoft\Windows\Windows Search"
    if (-not (Test-Path $cortanaPath)) {
        New-Item -Path $cortanaPath -Force | Out-Null
    }
    Set-ItemProperty -Path $cortanaPath -Name "AllowCortana" -Value 0
} 
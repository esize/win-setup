#Requires -RunAsAdministrator
[CmdletBinding()]
param()

# Set script location as working directory
$scriptPath = Split-Path -Parent $MyInvocation.MyCommand.Path
Set-Location $scriptPath

# Import utility functions
. "$scriptPath\utils\Write-Log.ps1"
. "$scriptPath\utils\Check-AdminRights.ps1"

# Import configuration modules
. "$scriptPath\modules\Set-SystemPreferences.ps1"
. "$scriptPath\modules\Set-VisualPreferences.ps1"
. "$scriptPath\modules\Set-ShellPreferences.ps1"
. "$scriptPath\modules\Install-WSL.ps1"
. "$scriptPath\modules\Set-StartMenuPreferences.ps1"
. "$scriptPath\modules\Set-SystemTweaks.ps1"
. "$scriptPath\modules\Install-PowerShell7.ps1"

. "$scriptPath\modules\Install-Applications.ps1"

# Start configuration
Write-Log "Starting Windows 11 configuration..."

try {
    # Verify admin rights
    if (-not (Test-AdminRights)) {
        throw "Script must be run as administrator!"
    }

    # Configure system settings
    Write-Log "Configuring system preferences..."
    Set-SystemPreferences

    # Configure visual preferences
    Write-Log "Configuring visual preferences..."
    Set-VisualPreferences

    # Configure shell preferences
    Write-Log "Configuring shell preferences..."
    Set-ShellPreferences

    # Install WSL2 and Ubuntu
    Write-Log "Installing WSL2 and Ubuntu..."
    Install-WSL

    # Configure Start Menu preferences
    Write-Log "Configuring Start Menu preferences..."
    Set-StartMenuPreferences

    # Configure system tweaks
    Write-Log "Configuring system tweaks..."
    Set-SystemTweaks
    
    
    # Ensure PowerShell 7
    Write-Log "Ensuring PowerShell 7..."
    Install-PowerShell7

    # Install applications
    Write-Log "Installing applications..."
    Install-Applications


    Write-Log "Configuration completed successfully!"
}
catch {
    Write-Log "Error occurred: $_" -Level Error
    exit 1
} 
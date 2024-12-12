#Requires -RunAsAdministrator
[CmdletBinding()]
param(
    [Parameter()]
    [switch]$SkipApps,
    
    [Parameter()]
    [switch]$SkipWSL
)

# Set script location as working directory
$scriptPath = Split-Path -Parent $MyInvocation.MyCommand.Path
Set-Location $scriptPath

# Import utility functions
. "$scriptPath\utils\Write-Log.ps1"
. "$scriptPath\utils\Check-AdminRights.ps1"
. "$scriptPath\utils\Restart-Explorer.ps1"

# Import configuration modules
. "$scriptPath\modules\Set-SystemPreferences.ps1"
. "$scriptPath\modules\Set-VisualPreferences.ps1"
. "$scriptPath\modules\Set-ShellPreferences.ps1"
. "$scriptPath\modules\Install-WSL.ps1"
. "$scriptPath\modules\Set-StartMenuPreferences.ps1"
. "$scriptPath\modules\Set-SystemTweaks.ps1"
. "$scriptPath\modules\Install-PowerShell7.ps1"
. "$scriptPath\modules\Remove-DefaultApps.ps1"

. "$scriptPath\modules\Install-Applications.ps1"
. "$scriptPath\modules\Install-Fonts.ps1"
. "$scriptPath\modules\Set-TerminalPreferences.ps1"

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

    # Configure taskbar pinned apps
    Write-Log "Configuring taskbar pinned apps..."
    Set-TaskbarPinnedApps

    # Install WSL2 and Ubuntu
    if (-not $SkipWSL) {
        Write-Log "Installing WSL2 and Ubuntu..."
        Install-WSL
    } else {
        Write-Log "Skipping WSL installation..." -Level Information
    }

    # Configure Start Menu preferences
    Write-Log "Configuring Start Menu preferences..."
    Set-StartMenuPreferences

    # Configure system tweaks
    Write-Log "Configuring system tweaks..."
    Set-SystemTweaks
    
    # Ensure PowerShell 7
    Write-Log "Ensuring PowerShell 7..."
    Install-PowerShell7

    # Remove default apps
    Write-Log "Removing default Windows applications..."
    Remove-DefaultApps

    # Install applications
    if (-not $SkipApps) {
        Write-Log "Installing applications..."
        Install-Applications
    } else {
        Write-Log "Skipping application installation..." -Level Information
    }

    # Install GeistMono Nerd Font
    Write-Log "Installing GeistMono Nerd Font..."
    Install-GeistMonoFont

    # Configure Windows Terminal
    Write-Log "Configuring Windows Terminal..."
    Set-TerminalPreferences

    # Wait for all processes to complete
    Write-Log "Waiting for all changes to apply..."
    Start-Sleep -Seconds 10

    # Prompt for restart
    Write-Log "Configuration complete! A restart is required to apply all changes."
    $restart = Read-Host "Would you like to restart now? (y/n)"
    
    if ($restart -eq 'y' -or $restart -eq 'Y') {
        Write-Log "Restarting computer in 10 seconds..."
        Start-Sleep -Seconds 10
        Restart-Computer -Force
    } else {
        Write-Log "Please restart your computer manually to apply all changes."
    }
}
catch {
    Write-Log "An error occurred during configuration: $_" -Level Error
    exit 1
} 
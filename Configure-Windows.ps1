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


# Import utilities
. "$scriptPath\utils\Write-Log.ps1"
. "$scriptPath\utils\Check-AdminRights.ps1"
. "$scriptPath\utils\Restart-Explorer.ps1"
. "$scriptPath\utils\Write-ProgressBar.ps1"

# Check for debug configuration
$debugConfigPath = "$env:USERPROFILE\win-setup-debug.json"
$debugConfig = $null
if (Test-Path $debugConfigPath) {
    $debugConfig = Get-Content $debugConfigPath | ConvertFrom-Json
    Write-Log -Level WARN "Debug configuration found!"
}

# Configure logging based on debug settings
if ($debugConfig.debug.verbose) {
    $VerbosePreference = 'Continue'
}

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
try {
    # Verify admin rights
    $isAdmin = Test-AdminRights
    if (-not $isAdmin) {
        Write-Log -Level ERROR "Script must be run as administrator!"
        exit 1
    }
    Write-Log -Level INFO "Starting Windows 11 configuration..."

    # Configure system settings
    Write-Log -Level INFO "Configuring system preferences..."
    Set-SystemPreferences

    # Configure visual preferences
    Write-Log -Level INFO "Configuring visual preferences..."
    Set-VisualPreferences

    # Configure shell preferences
    Write-Log -Level INFO "Configuring shell preferences..."
    Set-ShellPreferences

    # Install WSL2 and Ubuntu (unless disabled)
    if (-not ($debugConfig.system.disableWSL)) {
        Write-Log -Level INFO "Installing WSL2 and Ubuntu..."
        Install-WSL
    } else {
        Write-Log -Level INFO "Skipping WSL installation (debug option)"
    }

    # Configure Start Menu preferences
    Write-Log -Level INFO "Configuring Start Menu preferences..."
    Set-StartMenuPreferences

    # Configure system tweaks
    Write-Log -Level INFO "Configuring system tweaks..."
    Set-SystemTweaks
    
    # Ensure PowerShell 7 (unless disabled)
    if (-not ($debugConfig.system.skipPowerShell)) {
        Write-Log -Level INFO "Ensuring PowerShell 7..."
        Install-PowerShell7
    } else {
        Write-Log -Level INFO "Skipping PowerShell 7 installation (debug option)"
    }

    # Remove default apps
    Write-Log -Level INFO "Removing default Windows applications..."
    Remove-DefaultApps

    # Install applications (unless disabled)
    if (-not ($debugConfig.system.skipApplications)) {
        Write-Log -Level INFO "Installing applications..."
        Install-Applications
    } else {
        Write-Log -Level INFO "Skipping application installation (debug option)"
    }

    # Install GeistMono Nerd Font (unless disabled)
    if (-not ($debugConfig.system.skipFonts)) {
        Write-Log -Level INFO "Installing GeistMono Nerd Font..."
        Install-GeistMonoFont
    } else {
        Write-Log -Level INFO "Skipping font installation (debug option)"
    }

    # Configure Windows Terminal (unless disabled)
    if (-not ($debugConfig.system.skipTerminal)) {
        Write-Log -Level INFO "Configuring Windows Terminal..."
        Set-TerminalPreferences
    } else {
        Write-Log -Level INFO "Skipping terminal configuration (debug option)"
    }

    # Wait for all processes to complete
    Write-Log -Level INFO "Waiting for all changes to apply..."
    Start-Sleep -Seconds 10

    # Prompt for restart (unless disabled)
    if (-not ($debugConfig.debug.skipRestart)) {
        Write-Log -Level INFO "Configuration complete! A restart is required to apply all changes."
        $restart = Read-Host "Would you like to restart now? (y/n)"
        
        if ($restart -eq 'y' -or $restart -eq 'Y') {
            Write-Log -Level INFO "Restarting computer in 10 seconds..."
            Start-Sleep -Seconds 10
            Restart-Computer -Force
        } else {
            Write-Log -Level INFO "Please restart your computer manually to apply all changes."
        }
    } else {
        Write-Log -Level INFO "Configuration complete! Please restart your computer manually to apply all changes."
    }
}
catch {
    Write-Log -Level ERROR "An error occurred during configuration: $_"
    exit 1
} 
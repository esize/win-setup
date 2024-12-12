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
$utilsPath = Join-Path $scriptPath "utils"
$WriteLogPath = Join-Path $utilsPath "Write-Log.ps1"

# Import Write-Log first since other scripts depend on it
if (Test-Path $WriteLogPath) {
    . $WriteLogPath
} else {
    throw "Required utility Write-Log.ps1 not found at: $WriteLogPath"
}

# Import remaining utilities
. (Join-Path $utilsPath "Check-AdminRights.ps1")
. (Join-Path $utilsPath "Restart-Explorer.ps1")
. (Join-Path $utilsPath "Write-ProgressBar.ps1")

# Add this after setting $utilsPath
Write-Host "Utils path: $utilsPath"
Write-Host "Write-Log path: $(Join-Path $utilsPath 'Write-Log.ps1')"
if (Test-Path (Join-Path $utilsPath 'Write-Log.ps1')) {
    Write-Host "Write-Log.ps1 file exists"
} else {
    Write-Host "Write-Log.ps1 file not found"
}

# Check for debug configuration
$debugConfigPath = "$env:USERPROFILE\win-setup-debug.json"
$debugConfig = $null
if (Test-Path $debugConfigPath) {
    $debugConfig = Get-Content $debugConfigPath | ConvertFrom-Json
    Write-Log "Debug configuration found!" -Level Warning
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
        Write-Host "❌ Script must be run as administrator!" -ForegroundColor Red
        exit 1
    }
    Write-Log "Starting Windows 11 configuration..."

    # Configure system settings
    Write-Log "Configuring system preferences..."
    Set-SystemPreferences

    # Configure visual preferences
    Write-Log "Configuring visual preferences..."
    Set-VisualPreferences

    # Configure shell preferences
    Write-Log "Configuring shell preferences..."
    Set-ShellPreferences

    # Install WSL2 and Ubuntu (unless disabled)
    if (-not ($debugConfig.system.disableWSL)) {
        Write-Log "Installing WSL2 and Ubuntu..."
        Install-WSL
    } else {
        Write-Log "Skipping WSL installation (debug option)" -Level Information
    }

    # Configure Start Menu preferences
    Write-Log "Configuring Start Menu preferences..."
    Set-StartMenuPreferences

    # Configure system tweaks
    Write-Log "Configuring system tweaks..."
    Set-SystemTweaks
    
    # Ensure PowerShell 7 (unless disabled)
    if (-not ($debugConfig.system.skipPowerShell)) {
        Write-Log "Ensuring PowerShell 7..."
        Install-PowerShell7
    } else {
        Write-Log "Skipping PowerShell 7 installation (debug option)" -Level Information
    }

    # Remove default apps
    Write-Log "Removing default Windows applications..."
    Remove-DefaultApps

    # Install applications (unless disabled)
    if (-not ($debugConfig.system.skipApplications)) {
        Write-Log "Installing applications..."
        Install-Applications
    } else {
        Write-Log "Skipping application installation (debug option)" -Level Information
    }

    # Install GeistMono Nerd Font (unless disabled)
    if (-not ($debugConfig.system.skipFonts)) {
        Write-Log "Installing GeistMono Nerd Font..."
        Install-GeistMonoFont
    } else {
        Write-Log "Skipping font installation (debug option)" -Level Information
    }

    # Configure Windows Terminal (unless disabled)
    if (-not ($debugConfig.system.skipTerminal)) {
        Write-Log "Configuring Windows Terminal..."
        Set-TerminalPreferences
    } else {
        Write-Log "Skipping terminal configuration (debug option)" -Level Information
    }

    # Wait for all processes to complete
    Write-Log "Waiting for all changes to apply..."
    Start-Sleep -Seconds 10

    # Prompt for restart (unless disabled)
    if (-not ($debugConfig.debug.skipRestart)) {
        Write-Log "Configuration complete! A restart is required to apply all changes."
        $restart = Read-Host "Would you like to restart now? (y/n)"
        
        if ($restart -eq 'y' -or $restart -eq 'Y') {
            Write-Log "Restarting computer in 10 seconds..."
            Start-Sleep -Seconds 10
            Restart-Computer -Force
        } else {
            Write-Log "Please restart your computer manually to apply all changes."
        }
    } else {
        Write-Log "Configuration complete! Please restart your computer manually to apply all changes."
    }
}
catch {
    Write-Log "An error occurred during configuration: $_" -Level Error
    exit 1
} 
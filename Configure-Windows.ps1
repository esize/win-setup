#Requires -RunAsAdministrator
[CmdletBinding()]
param(
    [Parameter()]
    [switch]$SkipApps,
    
    [Parameter()]
    [switch]$SkipWSL
)

# Install and import PoShLog if not already installed
if (-not (Get-Module -ListAvailable -Name PoShLog)) {
    Write-Host "Installing PoShLog module..."
    Install-Module -Name PoShLog -Force -AllowClobber
}

Import-Module PoShLog

# Create custom theme
$customTheme = @{
    Debug = "#8AADF4"      # Blue
    Information = "#A6DA95" # Green
    Warning = "#EED49F"     # Yellow
    Error = "#ED8796"       # Red
    Fatal = "#F5BDE6"       # Purple
    Verbose = "#8BD5CA"     # Cyan
}

New-Logger |
    Set-MinimumLevel -Value Debug |
    Add-SinkFile -Path "logs/script.log" -RestrictedToMinimumLevel Debug |
    Add-SinkConsole -Theme $customTheme -OutputTemplate "[{Level:u3}] {Message}{NewLine}" |
    Start-Logger


Write-VerboseLog 'Test verbose message'
Write-DebugLog 'Test debug message'
Write-InfoLog 'Test info message'
Write-WarningLog 'Test warning message'
Write-ErrorLog 'Test error message'
Write-FatalLog 'Test fatal message'

# Set script location as working directory
$scriptPath = Split-Path -Parent $MyInvocation.MyCommand.Path
Set-Location $scriptPath


# Import remaining utilities
. (Join-Path $utilsPath "Check-AdminRights.ps1")
. (Join-Path $utilsPath "Restart-Explorer.ps1")
. (Join-Path $utilsPath "Write-ProgressBar.ps1")

# Check for debug configuration
$debugConfigPath = "$env:USERPROFILE\win-setup-debug.json"
$debugConfig = $null
if (Test-Path $debugConfigPath) {
    $debugConfig = Get-Content $debugConfigPath | ConvertFrom-Json
    Write-WarningLog "Debug configuration found!"
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
        Write-ErrorLog "Script must be run as administrator!"
        exit 1
    }
    Write-InfoLog "Starting Windows 11 configuration..."

    # Configure system settings
    Write-InfoLog "Configuring system preferences..."
    Set-SystemPreferences

    # Configure visual preferences
    Write-InfoLog "Configuring visual preferences..."
    Set-VisualPreferences

    # Configure shell preferences
    Write-InfoLog "Configuring shell preferences..."
    Set-ShellPreferences

    # Install WSL2 and Ubuntu (unless disabled)
    if (-not ($debugConfig.system.disableWSL)) {
        Write-InfoLog "Installing WSL2 and Ubuntu..."
        Install-WSL
    } else {
        Write-InfoLog "Skipping WSL installation (debug option)"
    }

    # Configure Start Menu preferences
    Write-InfoLog "Configuring Start Menu preferences..."
    Set-StartMenuPreferences

    # Configure system tweaks
    Write-InfoLog "Configuring system tweaks..."
    Set-SystemTweaks
    
    # Ensure PowerShell 7 (unless disabled)
    if (-not ($debugConfig.system.skipPowerShell)) {
        Write-InfoLog "Ensuring PowerShell 7..."
        Install-PowerShell7
    } else {
        Write-InfoLog "Skipping PowerShell 7 installation (debug option)"
    }

    # Remove default apps
    Write-InfoLog "Removing default Windows applications..."
    Remove-DefaultApps

    # Install applications (unless disabled)
    if (-not ($debugConfig.system.skipApplications)) {
        Write-InfoLog "Installing applications..."
        Install-Applications
    } else {
        Write-InfoLog "Skipping application installation (debug option)"
    }

    # Install GeistMono Nerd Font (unless disabled)
    if (-not ($debugConfig.system.skipFonts)) {
        Write-InfoLog "Installing GeistMono Nerd Font..."
        Install-GeistMonoFont
    } else {
        Write-InfoLog "Skipping font installation (debug option)"
    }

    # Configure Windows Terminal (unless disabled)
    if (-not ($debugConfig.system.skipTerminal)) {
        Write-InfoLog "Configuring Windows Terminal..."
        Set-TerminalPreferences
    } else {
        Write-InfoLog "Skipping terminal configuration (debug option)"
    }

    # Wait for all processes to complete
    Write-InfoLog "Waiting for all changes to apply..."
    Start-Sleep -Seconds 10

    # Prompt for restart (unless disabled)
    if (-not ($debugConfig.debug.skipRestart)) {
        Write-InfoLog "Configuration complete! A restart is required to apply all changes."
        $restart = Read-Host "Would you like to restart now? (y/n)"
        
        if ($restart -eq 'y' -or $restart -eq 'Y') {
            Write-InfoLog "Restarting computer in 10 seconds..."
            Start-Sleep -Seconds 10
            Restart-Computer -Force
        } else {
            Write-InfoLog "Please restart your computer manually to apply all changes."
        }
    } else {
        Write-InfoLog "Configuration complete! Please restart your computer manually to apply all changes."
    }
}
catch {
    Write-ErrorLog "An error occurred during configuration: $_"
    exit 1
}
finally {
    Close-Logger
} 
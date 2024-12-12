function Write-Log {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $true)]
        [string]$Message,
        
        [Parameter(Mandatory = $false)]
        [ValidateSet('Information', 'Warning', 'Error', 'Success', 'Debug')]
        [string]$Level = 'Information',
        
        [Parameter(Mandatory = $false)]
        [string]$LogFilePath = "$(Get-Location)\logs\script.log",
        
        [Parameter(Mandatory = $false)]
        [switch]$NoConsole
    )
    
    # Create logs directory if it doesn't exist
    $LogDir = Split-Path $LogFilePath -Parent
    if (-not (Test-Path $LogDir)) {
        New-Item -ItemType Directory -Path $LogDir -Force | Out-Null
    }

    # Get current timestamp (for file logging only)
    $Timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
    
    # Define log symbols and colors
    $LogStyles = @{
        Information = @{
            Symbol = '→'
            Color = 'Cyan'
        }
        Warning = @{
            Symbol = '⚠'
            Color = 'Yellow'
        }
        Error = @{
            Symbol = '✗'
            Color = 'Red'
        }
        Success = @{
            Symbol = '✓'
            Color = 'Green'
        }
        Debug = @{
            Symbol = '🔧'
            Color = 'Gray'
        }
    }
    
    # Create the log entries
    $FileLogEntry = "[$Timestamp] [$Level] $Message"
    $ConsoleLogEntry = "  $($LogStyles[$Level].Symbol) $Message"
    
    # Write to log file
    try {
        Add-Content -Path $LogFilePath -Value $FileLogEntry -ErrorAction Stop
    }
    catch {
        Write-Error "Failed to write to log file: $_"
    }
    
    # Write to console if not suppressed
    if (-not $NoConsole) {
        Write-Host $ConsoleLogEntry -ForegroundColor $LogStyles[$Level].Color
    }
}

function Write-Log {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $true)]
        [string]$Message,
        
        [Parameter(Mandatory = $false)]
        [ValidateSet('INFO', 'WARN', 'ERROR', 'DEBUG', 'SUCCESS')]
        [string]$Level = 'INFO',
        
        [Parameter(Mandatory = $false)]
        [string]$LogFile = "$(Get-Date -Format 'yyyy-MM-dd')-script.log"
    )

    # Create timestamp
    $Timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
    
    # Define colors and prefixes for different log levels
    $LogConfig = @{
        'SUCCESS' = @{
            Color = 'Green'
            Prefix = '✓'
        }
        'INFO'  = @{
            Color = 'Cyan'
            Prefix = ''
        }
        'WARN'  = @{
            Color = 'Yellow'
            Prefix = '⚠'
        }
        'ERROR' = @{
            Color = 'Red'
            Prefix = '✗'
        }
        'DEBUG' = @{
            Color = 'DarkGray'
            Prefix = ''
        }
    }

    # Create log entry for file (with timestamp)
    $LogEntry = "[$Timestamp] [$Level] $Message"
    
    # Create console output (without timestamp)
    $ConsolePrefix = if ($LogConfig[$Level].Prefix) { "$($LogConfig[$Level].Prefix) " } else { "" }
    $ConsoleMessage = "[$Level] $Message"
    
    # Write to console with color
    Write-Host $ConsolePrefix -NoNewline -ForegroundColor $LogConfig[$Level].Color
    Write-Host $ConsoleMessage

    # Ensure log directory exists
    $LogDir = Split-Path $LogFile -Parent
    if ($LogDir -and !(Test-Path $LogDir)) {
        New-Item -ItemType Directory -Path $LogDir -Force | Out-Null
    }

    # Write to log file
    Add-Content -Path $LogFile -Value $LogEntry
}

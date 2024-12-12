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
    
    # Define colors and emojis for different log levels
    $LogConfig = @{
        'SUCCESS' = @{
            Color = 'Green'
            Emoji = '✅'
            Prefix = ' '
        }
        'INFO'  = @{
            Color = 'Cyan'
            Emoji = '📝'
            Prefix = '   '
        }
        'WARN'  = @{
            Color = 'Yellow'
            Emoji = '⚠️'
            Prefix = '  '
        }
        'ERROR' = @{
            Color = 'Red'
            Emoji = '❌'
            Prefix = '  '
        }
        'DEBUG' = @{
            Color = 'Gray'
            Emoji = '🔍'
            Prefix = '  '
        }
    }

    # Create log entry for file (without emoji)
    $LogEntry = "[$Timestamp] [$Level] $Message"
    
    # Write to console with enhanced formatting
    Write-Host -NoNewline "`n$($LogConfig[$Level].Emoji) " # Emoji with space
    Write-Host -NoNewline "[$Timestamp] " -ForegroundColor DarkGray
    Write-Host -NoNewline "$($LogConfig[$Level].Prefix)[$Level] " -ForegroundColor $LogConfig[$Level].Color
    
    # Add horizontal line for ERROR level or checkmark line for SUCCESS
    if ($Level -eq 'ERROR') {
        $Message = "$Message`n$($LogConfig[$Level].Prefix)$('─' * 50)"
    }
    elseif ($Level -eq 'SUCCESS') {
        $Message = "$Message`n$($LogConfig[$Level].Prefix)$('─' * 25)$('✓')$('─' * 24)"
    }
    
    Write-Host $Message
    
    # Add extra line break after each log entry
    Write-Host ""

    # Ensure log directory exists
    $LogDir = Split-Path $LogFile -Parent
    if ($LogDir -and !(Test-Path $LogDir)) {
        New-Item -ItemType Directory -Path $LogDir -Force | Out-Null
    }

    # Write to log file (clean format without emojis and extra formatting)
    Add-Content -Path $LogFile -Value $LogEntry
}

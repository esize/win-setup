function Write-Log {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $true)]
        [string]$Message,
        
        [Parameter(Mandatory = $false)]
        [ValidateSet('Information', 'Warning', 'Error', 'Success', 'Debug')]
        [string]$Level = 'Information'
    )
    
    $Colors = @{
        Information = 'Cyan'
        Warning = 'Yellow'
        Error = 'Red'
        Success = 'Green'
        Debug = 'Gray'
    }

    $Symbols = @{
        Information = '→'
        Warning = '⚠'
        Error = '✗'
        Success = '✓'
        Debug = '🔧'
    }

    $timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
    $logMessage = "  $($Symbols[$Level]) $Message"
    
    # Write to console with appropriate color
    Write-Host $logMessage -ForegroundColor $Colors[$Level]
    
    # Write to log file if logging directory exists
    $logDir = Join-Path (Get-Location) "logs"
    $logFile = Join-Path $logDir "script.log"
    
    if (-not (Test-Path $logDir)) {
        New-Item -ItemType Directory -Path $logDir -Force | Out-Null
    }
    
    "[$timestamp] [$Level] $Message" | Add-Content -Path $logFile -ErrorAction SilentlyContinue
}

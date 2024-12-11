function Write-Log {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $true)]
        [string]$Message,
        
        [Parameter(Mandatory = $false)]
        [ValidateSet('Information', 'Warning', 'Error', 'Debug')]
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

    # Get current timestamp
    $Timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
    
    # Define log colors for console output
    $LogColors = @{
        'Information' = 'White'
        'Warning' = 'Yellow'
        'Error' = 'Red'
        'Debug' = 'Cyan'
    }
    
    # Create the log entry
    $LogEntry = "[$Timestamp] [$Level] $Message"
    
    # Write to log file
    try {
        Add-Content -Path $LogFilePath -Value $LogEntry -ErrorAction Stop
    }
    catch {
        Write-Error "Failed to write to log file: $_"
    }
    
    # Write to console if not suppressed
    if (-not $NoConsole) {
        Write-Host $LogEntry -ForegroundColor $LogColors[$Level]
    }
}

function Write-ProgressBar {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $true)]
        [int]$Current,
        
        [Parameter(Mandatory = $true)]
        [int]$Total,
        
        [Parameter(Mandatory = $false)]
        [string]$Message = "Progress"
    )

    $progressPercentage = [math]::Round(($Current / $Total) * 100)
    $progressBar = "[" + ("=" * [math]::Floor($progressPercentage / 2)) + (" " * (50 - [math]::Floor($progressPercentage / 2))) + "]"
    
    # Clear the previous line
    Write-Log -Message "`r" -NoConsole:$false
    
    # Display current progress
    Write-Log -Message "`r$Message $progressBar [$Current/$Total] ($progressPercentage%)" -NoConsole:$false
    
    # Add newline if complete
    if ($Current -eq $Total) {
        Write-Log "" -NoConsole:$false
    }
} 
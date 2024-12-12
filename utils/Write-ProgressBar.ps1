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
    
    Write-Log "$Message $progressBar [$Current/$Total] ($progressPercentage%)" -Level INFO
} 
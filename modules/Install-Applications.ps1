function Install-PowerShell7 {
    [CmdletBinding()]
    param()

    Write-Log "Checking PowerShell version..."
    
    # Check if PowerShell 7 is already installed
    $pwsh = Get-Command pwsh -ErrorAction SilentlyContinue
    
    if (-not $pwsh) {
        Write-Log "PowerShell 7 not found. Installing..."
        try {
            # Install PowerShell 7 using winget
            winget install --id Microsoft.PowerShell --source winget --accept-source-agreements --accept-package-agreements
            
            # Refresh environment variables
            $env:Path = [System.Environment]::GetEnvironmentVariable("Path","Machine") + ";" + [System.Environment]::GetEnvironmentVariable("Path","User")
            
            Write-Log "PowerShell 7 installed successfully!"
        }
        catch {
            Write-Log "Failed to install PowerShell 7: $_" -Level Error
            throw
        }
    }
    else {
        Write-Log "PowerShell 7 is already installed."
    }

    # Get the current PowerShell version
    $currentVersion = $PSVersionTable.PSVersion.Major
    
    # If not running in PowerShell 7, restart the script in PowerShell 7
    if ($currentVersion -lt 7) {
        Write-Log "Restarting script in PowerShell 7..."
        $scriptPath = $MyInvocation.MyCommand.Path
        $arguments = $MyInvocation.BoundParameters.GetEnumerator() | ForEach-Object { "-$($_.Key) `"$($_.Value)`"" }
        
        # Start the script in PowerShell 7
        Start-Process pwsh -ArgumentList "-NoExit -File `"$scriptPath`" $arguments" -Wait
        exit
    }
} 
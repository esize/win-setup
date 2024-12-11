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
            Install-Application -appId Microsoft.PowerShell
            
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
    
    # Only restart in PowerShell 7 if we're running in an older version
    if ($currentVersion -lt 7) {
        Write-Log "Restarting script in PowerShell 7..."
        
        # Save current script path and arguments
        $scriptPath = $MyInvocation.MyCommand.Path
        $arguments = $MyInvocation.BoundParameters.GetEnumerator() | ForEach-Object { "-$($_.Key) `"$($_.Value)`"" }
        
        # Change directory to avoid file lock issues
        Set-Location $env:USERPROFILE
        
        # Start PowerShell 7 with the script
        $process = Start-Process pwsh -ArgumentList "-NoExit -File `"$scriptPath`" $arguments" -PassThru -Wait
        
        # Exit the current PowerShell session
        exit $process.ExitCode
    }
    else {
        Write-Log "Already running in PowerShell 7, continuing..."
    }
} 
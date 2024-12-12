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
}
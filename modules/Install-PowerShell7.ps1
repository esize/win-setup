function Install-PowerShell7 {
    [CmdletBinding()]
    param()

    Write-Log -Level DEBUG "Checking PowerShell version..."
    
    # Check if PowerShell 7 is already installed
    $pwsh = Get-Command pwsh -ErrorAction SilentlyContinue
    
    if (-not $pwsh) {
        Write-Log -Level INFO "PowerShell 7 not found. Installing..."
        try {
            # Install PowerShell 7 using winget
            Install-Application -appId Microsoft.PowerShell
            
            # Refresh environment variables
            $env:Path = [System.Environment]::GetEnvironmentVariable("Path","Machine") + ";" + [System.Environment]::GetEnvironmentVariable("Path","User")
            
            Write-Log -Level INFO "PowerShell 7 installed successfully!"
        }
        catch {
            Write-Log -Level ERROR "Failed to install PowerShell 7: $_"
            throw
        }
    }
    else {
        Write-Log -Level DEBUG "PowerShell 7 is already installed."
    }
}
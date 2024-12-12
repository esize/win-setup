function Install-PowerShell7 {
    [CmdletBinding()]
    param()

    Write-VerboseLog "Checking PowerShell version..."
    
    # Check if PowerShell 7 is already installed
    $pwsh = Get-Command pwsh -ErrorAction SilentlyContinue
    
    if (-not $pwsh) {
        Write-InfoLog "PowerShell 7 not found. Installing..."
        try {
            # Install PowerShell 7 using winget
            Install-Application -appId Microsoft.PowerShell
            
            # Refresh environment variables
            $env:Path = [System.Environment]::GetEnvironmentVariable("Path","Machine") + ";" + [System.Environment]::GetEnvironmentVariable("Path","User")
            
            Write-SuccessLog "PowerShell 7 installed successfully!"
        }
        catch {
            Write-ErrorLog "Failed to install PowerShell 7: $_"
            throw
        }
    }
    else {
        Write-VerboseLog "PowerShell 7 is already installed."
    }
}
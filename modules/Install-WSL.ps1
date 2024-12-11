function Install-WSL {
    [CmdletBinding()]
    param()

    Write-Log "Starting WSL2 installation..."

    try {
        # Enable Windows Subsystem for Linux
        Write-Log "Enabling Windows Subsystem for Linux feature..."
        dism.exe /online /enable-feature /featurename:Microsoft-Windows-Subsystem-Linux /all /norestart

        # Enable Virtual Machine Platform
        Write-Log "Enabling Virtual Machine Platform feature..."
        dism.exe /online /enable-feature /featurename:VirtualMachinePlatform /all /norestart

        # Download and install WSL2 kernel update
        Write-Log "Downloading WSL2 kernel update..."
        $wslUpdateUrl = "https://wslstorestorage.blob.core.windows.net/wslblob/wsl_update_x64.msi"
        $wslUpdateFile = "$env:TEMP\wsl_update_x64.msi"
        Invoke-WebRequest -Uri $wslUpdateUrl -OutFile $wslUpdateFile
        
        Write-Log "Installing WSL2 kernel update..."
        Start-Process msiexec.exe -ArgumentList "/i `"$wslUpdateFile`" /quiet /norestart" -Wait

        # Set WSL2 as default
        Write-Log "Setting WSL2 as default version..."
        wsl --set-default-version 2

        # Install Ubuntu 24.04
        Write-Log "Installing Ubuntu 24.04..."
        winget install -e --id Canonical.Ubuntu.2204 --accept-source-agreements --accept-package-agreements

        Write-Log "WSL2 and Ubuntu installation completed successfully!"
        Write-Log "Note: A system restart may be required to complete the installation." -Level Warning
    }
    catch {
        Write-Log "Failed to install WSL2: $_" -Level Error
        throw
    }
    finally {
        # Cleanup
        if (Test-Path $wslUpdateFile) {
            Remove-Item $wslUpdateFile -Force
        }
    }
} 
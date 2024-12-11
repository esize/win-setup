function Install-WSL {
    [CmdletBinding()]
    param()

    Write-Log "Starting WSL2 installation..."

    try {
        # Enable Windows Subsystem for Linux (non-interactive)
        Write-Log "Enabling Windows Subsystem for Linux feature..."
        dism.exe /online /enable-feature /featurename:Microsoft-Windows-Subsystem-Linux /all /norestart /quiet

        # Enable Virtual Machine Platform (non-interactive)
        Write-Log "Enabling Virtual Machine Platform feature..."
        dism.exe /online /enable-feature /featurename:VirtualMachinePlatform /all /norestart /quiet

        # Download and install WSL2 kernel update
        Write-Log "Downloading WSL2 kernel update..."
        $wslUpdateUrl = "https://wslstorestorage.blob.core.windows.net/wslblob/wsl_update_x64.msi"
        $wslUpdateFile = "$env:TEMP\wsl_update_x64.msi"
        Invoke-WebRequest -Uri $wslUpdateUrl -OutFile $wslUpdateFile
        
        Write-Log "Installing WSL2 kernel update..."
        Start-Process msiexec.exe -ArgumentList "/i `"$wslUpdateFile`" /quiet /norestart" -Wait -NoNewWindow

        # Install WSL using wsl --install command
        Write-Log "Installing WSL..."
        wsl --install --no-distribution --no-launch

        # Set WSL2 as default
        Write-Log "Setting WSL2 as default version..."
        wsl --set-default-version 2

        # Install Ubuntu using winget (completely non-interactive)
        Write-Log "Installing Ubuntu..."
        Install-Application -appId Canonical.Ubuntu.2404

        # Wait for Ubuntu installation to complete
        Start-Sleep -Seconds 10

        # Initialize Ubuntu distribution
        Write-Log "Initializing Ubuntu distribution..."
        wsl --install -d Ubuntu-24.04 --no-launch

        Write-Log "WSL2 and Ubuntu installation completed successfully!"
    }
    catch {
        Write-Log "Failed to install WSL2: $_" -Level Error
        throw
    }
    finally {
        if (Test-Path $wslUpdateFile) {
            Remove-Item $wslUpdateFile -Force
        }
    }
}
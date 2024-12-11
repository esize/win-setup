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

        # Set WSL2 as default
        Write-Log "Setting WSL2 as default version..."
        wsl --set-default-version 2

        # Install Ubuntu using winget (completely non-interactive)
        Write-Log "Installing Ubuntu..."
        winget install -e --id Canonical.Ubuntu.2404 --accept-source-agreements --accept-package-agreements --silent

        # Initialize Ubuntu (non-interactive)
        $ubuntuExe = "${env:LOCALAPPDATA}\Microsoft\WindowsApps\ubuntu2404.exe"
        if (Test-Path $ubuntuExe) {
            Start-Process $ubuntuExe -ArgumentList "install --root" -Wait -NoNewWindow
        }

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
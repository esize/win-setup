function Install-WSL {
    [CmdletBinding()]
    param()

    Write-InfoLog "Starting WSL2 installation..."
    $totalSteps = 7
    $currentStep = 0

    try {
        # Enable Windows Subsystem for Linux
        $currentStep++
        Write-ProgressBar -Current $currentStep -Total $totalSteps -Message "Enabling Windows Subsystem for Linux"
        dism.exe /online /enable-feature /featurename:Microsoft-Windows-Subsystem-Linux /all /norestart /quiet

        # Enable Virtual Machine Platform
        $currentStep++
        Write-ProgressBar -Current $currentStep -Total $totalSteps -Message "Enabling Virtual Machine Platform"
        dism.exe /online /enable-feature /featurename:VirtualMachinePlatform /all /norestart /quiet

        # Download WSL2 kernel update
        $currentStep++
        Write-ProgressBar -Current $currentStep -Total $totalSteps -Message "Downloading WSL2 kernel update"
        $wslUpdateUrl = "https://wslstorestorage.blob.core.windows.net/wslblob/wsl_update_x64.msi"
        $wslUpdateFile = "$env:TEMP\wsl_update_x64.msi"
        Invoke-WebRequest -Uri $wslUpdateUrl -OutFile $wslUpdateFile -UseBasicParsing -NoProgress

        # Install WSL2 kernel update
        $currentStep++
        Write-ProgressBar -Current $currentStep -Total $totalSteps -Message "Installing WSL2 kernel update"
        Start-Process msiexec.exe -ArgumentList "/i `"$wslUpdateFile`" /quiet /norestart" -Wait -NoNewWindow

        # Install WSL
        $currentStep++
        Write-ProgressBar -Current $currentStep -Total $totalSteps -Message "Installing WSL"
        wsl --install --no-distribution --no-launch

        # Set WSL2 as default
        $currentStep++
        Write-ProgressBar -Current $currentStep -Total $totalSteps -Message "Setting WSL2 as default"
        wsl --set-default-version 2

        # Install Ubuntu
        $currentStep++
        Write-ProgressBar -Current $currentStep -Total $totalSteps -Message "Installing Ubuntu"
        Install-Application -appId Canonical.Ubuntu.2404

        Write-SuccessLog "WSL2 and Ubuntu installation completed successfully!"
    }
    catch {
        Write-ErrorLog "Failed to install WSL2: $_"
        throw
    }
    finally {
        if (Test-Path $wslUpdateFile) {
            Remove-Item $wslUpdateFile -Force
        }
    }
}
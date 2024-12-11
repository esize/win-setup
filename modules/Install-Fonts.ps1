function Install-GeistMonoFont {
    [CmdletBinding()]
    param()

    Write-Log "Installing GeistMono Nerd Font..."

    $fontUrl = "https://github.com/ryanoasis/nerd-fonts/releases/download/v3.1.1/GeistMono.zip"
    $tempPath = "$env:TEMP\GeistMono"
    $fontsPath = "$env:WINDIR\Fonts"

    try {
        # Create temporary directory
        New-Item -ItemType Directory -Force -Path $tempPath | Out-Null

        # Download font
        $zipPath = "$tempPath\GeistMono.zip"
        Invoke-WebRequest -Uri $fontUrl -OutFile $zipPath

        # Extract fonts
        Expand-Archive -Path $zipPath -DestinationPath $tempPath -Force

        # Install fonts
        $fonts = Get-ChildItem -Path $tempPath -Filter "*.ttf" -Recurse
        foreach ($font in $fonts) {
            $fontName = $font.Name
            Write-Log "Installing font: $fontName"
            
            # Copy to Windows Fonts directory
            Copy-Item -Path $font.FullName -Destination $fontsPath -Force

            # Add font to registry
            $registryPath = "HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Fonts"
            $fontRegistryName = $fontName -replace ".ttf$", " (TrueType)"
            Set-ItemProperty -Path $registryPath -Name $fontRegistryName -Value $fontName -Type String
        }

        Write-Log "GeistMono Nerd Font installed successfully!"
    }
    catch {
        Write-Log "Failed to install GeistMono Nerd Font: $_" -Level Error
        throw
    }
    finally {
        # Cleanup
        if (Test-Path $tempPath) {
            Remove-Item -Path $tempPath -Recurse -Force
        }
    }
} 
function Install-GeistMonoFont {
    [CmdletBinding()]
    param()

    Write-Log "🔤 Installing GeistMono Nerd Font..." -Level Information
    
    $fontUrl = "https://github.com/ryanoasis/nerd-fonts/releases/download/v3.1.1/GeistMono.zip"
    $tempPath = "$env:TEMP\GeistMono"
    $fontsPath = "$env:WINDIR\Fonts"
    
    $steps = @(
        @{
            Name = "Creating temporary directory"
            Action = { New-Item -ItemType Directory -Force -Path $tempPath | Out-Null }
        }
        @{
            Name = "Downloading font package"
            Action = {
                $zipPath = "$tempPath\GeistMono.zip"
                Invoke-WebRequest -Uri $fontUrl -OutFile $zipPath
            }
        }
        @{
            Name = "Extracting font files"
            Action = {
                $zipPath = "$tempPath\GeistMono.zip"
                Expand-Archive -Path $zipPath -DestinationPath $tempPath -Force
            }
        }
        @{
            Name = "Installing fonts"
            Action = {
                $fonts = Get-ChildItem -Path $tempPath -Filter "*.ttf" -Recurse
                foreach ($font in $fonts) {
                    $fontName = $font.Name
                    Copy-Item -Path $font.FullName -Destination $fontsPath -Force
                    
                    # Add font to registry
                    $registryPath = "HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Fonts"
                    $fontRegistryName = $fontName -replace ".ttf$", " (TrueType)"
                    Set-ItemProperty -Path $registryPath -Name $fontRegistryName -Value $fontName -Type String
                }
            }
        }
        @{
            Name = "Verifying installation"
            Action = {
                $installedFonts = (New-Object System.Drawing.Text.InstalledFontCollection).Families.Name
                if ($installedFonts -notcontains "GeistMono Nerd Font Mono") {
                    throw "Font verification failed - GeistMono Nerd Font Mono not found in system fonts"
                }
            }
        }
    )

    foreach ($step in $steps) {
        Write-Log "  → $($step.Name)..." -Level Information
        
        try {
            & $step.Action
            Write-Log "  ✓ $($step.Name)" -Level Success
        }
        catch {
            Write-Log "  ✗ $($step.Name)" -Level Error
            Write-Log "    Error: $_" -Level Error
            throw
        }
    }

    # Cleanup
    Write-Log "  → Cleaning up..." -Level Information
    if (Test-Path $tempPath) {
        Remove-Item -Path $tempPath -Recurse -Force
        Write-Log "  ✓ Cleaning up" -Level Success
    }
    
    Write-Log "Font installation completed!" -Level Success
    Restart-Explorer
} 
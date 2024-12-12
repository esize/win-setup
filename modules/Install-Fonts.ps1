function Install-GeistMonoFont {
    [CmdletBinding()]
    param()

    Write-Host "`n🔤 Installing GeistMono Nerd Font..." -ForegroundColor Cyan
    
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
        Write-Host "  → $($step.Name)..." -NoNewline
        
        try {
            & $step.Action
            Write-Host "`r  ✓ $($step.Name)   " -ForegroundColor Green
        }
        catch {
            Write-Host "`r  ✗ $($step.Name)   " -ForegroundColor Red
            Write-Host "    Error: $_" -ForegroundColor Red
            throw
        }
    }

    # Cleanup
    Write-Host "`n  → Cleaning up..." -NoNewline
    if (Test-Path $tempPath) {
        Remove-Item -Path $tempPath -Recurse -Force
        Write-Host "`r  ✓ Cleaning up   " -ForegroundColor Green
    }
    
    Write-Host "`n✓ Font installation completed!" -ForegroundColor Green

    # Broadcast font change notification
    $signature = @'
[DllImport("user32.dll")]
public static extern int SendMessage(IntPtr hWnd, uint Msg, IntPtr wParam, IntPtr lParam);
'@
    Add-Type -MemberDefinition $signature -Name WinAPI -Namespace Win32
    [Win32.WinAPI]::SendMessage(-1, 0x001D, 0, 0) | Out-Null
} 
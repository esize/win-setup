function Install-GeistMonoFont {
    [CmdletBinding()]
    param()

    Write-InfoLog "Installing GeistMono Nerd Font..."

    try {
        # Define font URLs and paths
        $fontUrl = "https://github.com/ryanoasis/nerd-fonts/releases/download/v3.1.1/GeistMono.zip"
        $tempPath = Join-Path $env:TEMP "GeistMono"
        $fontZip = Join-Path $tempPath "GeistMono.zip"
        $fontsFolder = Join-Path $tempPath "fonts"
        $systemFontsPath = Join-Path $env:SystemRoot "Fonts"

        # Create temporary directory
        if (-not (Test-Path $tempPath)) {
            New-Item -ItemType Directory -Path $tempPath -Force | Out-Null
        }

        # Download font
        Write-VerboseLog "Downloading GeistMono Nerd Font..."
        Invoke-WebRequest -Uri $fontUrl -OutFile $fontZip -UseBasicParsing

        # Extract fonts
        Write-VerboseLog "Extracting fonts..."
        Expand-Archive -Path $fontZip -DestinationPath $fontsFolder -Force

        # Install fonts
        Write-VerboseLog "Installing fonts..."
        $fonts = Get-ChildItem -Path $fontsFolder -Include "*.ttf","*.otf" -Recurse
        foreach ($font in $fonts) {
            $destPath = Join-Path $systemFontsPath $font.Name
            
            # Copy font file to Windows Fonts directory
            Copy-Item -Path $font.FullName -Destination $destPath -Force

            # Add font to registry
            $regPath = "HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Fonts"
            $fontName = $font.Name -replace "\.(ttf|otf)$", " (TrueType)"
            Set-ItemProperty -Path $regPath -Name $fontName -Value $font.Name -Type String
        }

        # Reload font cache
        Write-VerboseLog "Reloading font cache..."
        $signature = @'
        [DllImport("gdi32.dll")]
        public static extern int AddFontResource(string lpFilename);
'@
        $gdi32 = Add-Type -MemberDefinition $signature -Name GDI32 -Namespace Win32 -PassThru
        $fonts | ForEach-Object { $gdi32::AddFontResource($_.FullName) | Out-Null }

        # Broadcast font change message
        $HWND_BROADCAST = 0xffff
        $WM_FONTCHANGE = 0x001D
        $null = Add-Type -TypeDefinition @'
        using System;
        using System.Runtime.InteropServices;
        public class Win32 {
            [DllImport("user32.dll")]
            public static extern IntPtr SendMessage(IntPtr hWnd, uint Msg, IntPtr wParam, IntPtr lParam);
        }
'@
        [Win32]::SendMessage($HWND_BROADCAST, $WM_FONTCHANGE, [IntPtr]::Zero, [IntPtr]::Zero)

        Write-SuccessLog "GeistMono Nerd Font installed successfully!"
    }
    catch {
        Write-ErrorLog "Failed to install GeistMono Nerd Font: $_"
        throw
    }
    finally {
        # Cleanup
        if (Test-Path $tempPath) {
            Remove-Item -Path $tempPath -Recurse -Force -ErrorAction SilentlyContinue
        }
    }
}
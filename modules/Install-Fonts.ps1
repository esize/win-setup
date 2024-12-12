function Install-GeistMonoFont {
    [CmdletBinding()]
    param()

    Write-InfoLog "Installing GeistMono Nerd Font..."
    
    # Cleanup
    Write-VerboseLog "  → Cleaning up..."
    if (Test-Path $tempPath) {
        Remove-Item -Path $tempPath -Recurse -Force
        Write-SuccessLog "  ✓ Cleaning up"
    }
    
    Write-SuccessLog "Font installation completed!"
    Restart-Explorer
} 
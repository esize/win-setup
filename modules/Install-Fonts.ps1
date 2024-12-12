function Install-GeistMonoFont {
    [CmdletBinding()]
    param()

    Write-Log "Installing GeistMono Nerd Font..."
    
    # Cleanup
    Write-Log "  → Cleaning up..." -Level Information
    if (Test-Path $tempPath) {
        Remove-Item -Path $tempPath -Recurse -Force
        Write-Log "  ✓ Cleaning up" -Level Success
    }
    
    Write-Log "Font installation completed!" -Level Success
    Restart-Explorer
} 
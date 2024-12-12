function Restart-Explorer {
    [CmdletBinding()]
    param()
    
    try {
        Write-Log -Level INFO "Restarting Explorer to apply changes..."
        # Stop Explorer process
        Stop-Process -Name explorer -Force -ErrorAction SilentlyContinue
        
        # Wait a moment for Explorer to fully stop
        Start-Sleep -Seconds 1
        
        # Start Explorer
        Start-Process explorer
        
        # Wait for Explorer to start
        Start-Sleep -Seconds 2
        
        # Close any File Explorer windows that were opened
        $shell = New-Object -ComObject Shell.Application
        $shell.Windows() | ForEach-Object {
            if ($_.FullName -like "*explorer.exe") {
                $_.Quit()
            }
        }
        
        # Clean up COM object
        [System.Runtime.Interopservices.Marshal]::ReleaseComObject($shell) | Out-Null
        Remove-Variable shell
    }
    catch {
        Write-Log -Level WARN "Failed to restart Explorer: $_"
    }
} 
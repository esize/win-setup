# Check and set execution policy
$currentPolicy = Get-ExecutionPolicy
if ($currentPolicy -ne "RemoteSigned" -and $currentPolicy -ne "Unrestricted") {
    try {
        Set-ExecutionPolicy RemoteSigned -Scope CurrentUser -Force
        Write-Host "Execution policy has been set to RemoteSigned for current user." -ForegroundColor Green
    }
    catch {
        Write-Host "Failed to set execution policy. Please run PowerShell as Administrator and run: Set-ExecutionPolicy RemoteSigned" -ForegroundColor Red
        exit 1
    }
}

# Define available debug options
$debugOptions = @{
    "Skip WSL Installation" = @{
        key = "disableWSL"
        category = "system"
        description = "Skip installation of WSL2 and Ubuntu"
        default = $false
    }
    "Skip Application Installation" = @{
        key = "skipApplications"
        category = "system"
        description = "Skip installation of applications via winget"
        default = $false
    }
    "Skip Font Installation" = @{
        key = "skipFonts"
        category = "system"
        description = "Skip installation of custom fonts"
        default = $false
    }
    "Skip Terminal Configuration" = @{
        key = "skipTerminal"
        category = "system"
        description = "Skip Windows Terminal configuration"
        default = $false
    }
    "Enable Verbose Logging" = @{
        key = "verbose"
        category = "debug"
        description = "Enable detailed logging output"
        default = $false
    }
    "Skip Restart Prompt" = @{
        key = "skipRestart"
        category = "debug"
        description = "Skip the restart prompt at the end"
        default = $false
    }
}

# Display menu
Write-Host "`n🔧 Windows Setup Debug Configuration`n" -ForegroundColor Cyan
Write-Host "Select debug options (space to toggle, enter when done):`n"

$selected = @{}
$currentOption = 0
$options = $debugOptions.Keys | Sort-Object

function Show-Menu {
    param (
        [int]$selectedIndex,
        [hashtable]$selectedItems
    )
    
    # Clear the console area for menu
    $host.UI.RawUI.CursorPosition = New-Object System.Management.Automation.Host.Coordinates 0, $host.UI.RawUI.CursorPosition.Y
    
    # Display all options
    for ($i = 0; $i -lt $options.Count; $i++) {
        $option = $options[$i]
        $prefix = if ($i -eq $selectedIndex) { ">" } else { " " }
        $status = if ($selectedItems[$option]) { "[×]" } else { "[ ]" }
        $color = if ($i -eq $selectedIndex) { "Cyan" } else { "White" }
        
        Write-Host "$prefix $status $option" -ForegroundColor $color
    }
    
    # Move cursor back up
    $host.UI.RawUI.CursorPosition = New-Object System.Management.Automation.Host.Coordinates 0, ($host.UI.RawUI.CursorPosition.Y - $options.Count)
}

# Initial menu render
Show-Menu -selectedIndex $currentOption -selectedItems $selected

# Menu loop
while ($true) {
    $key = $host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")
    
    switch ($key.VirtualKeyCode) {
        38 { # Up arrow
            $currentOption = if ($currentOption -eq 0) { $options.Count - 1 } else { $currentOption - 1 }
            Show-Menu -selectedIndex $currentOption -selectedItems $selected
        }
        40 { # Down arrow
            $currentOption = if ($currentOption -eq $options.Count - 1) { 0 } else { $currentOption + 1 }
            Show-Menu -selectedIndex $currentOption -selectedItems $selected
        }
        32 { # Space
            $selected[$options[$currentOption]] = -not $selected[$options[$currentOption]]
            Show-Menu -selectedIndex $currentOption -selectedItems $selected
        }
        13 { # Enter
            # Move cursor past menu
            $host.UI.RawUI.CursorPosition = New-Object System.Management.Automation.Host.Coordinates 0, ($host.UI.RawUI.CursorPosition.Y + $options.Count + 1)
            return
        }
    }
}

# Build configuration from selections
$debugConfig = @{
    system = @{}
    debug = @{}
}

$selected.Keys | ForEach-Object {
    $option = $debugOptions[$_]
    if ($option) {
        if (-not $debugConfig[$option.category]) {
            $debugConfig[$option.category] = @{}
        }
        $debugConfig[$option.category][$option.key] = $true
    }
}

# Save configuration
$debugConfigPath = "$env:USERPROFILE\win-setup-debug.json"
if (Test-Path $debugConfigPath) {
    Remove-Item -Path $debugConfigPath -Force
}
$debugConfig | ConvertTo-Json -Depth 3 | Set-Content $debugConfigPath

Write-Host "`n✓ Debug configuration saved to: $debugConfigPath" -ForegroundColor Green
Write-Host "`nSelected options:"
$selected.Keys | Where-Object { $selected[$_] } | ForEach-Object {
    Write-Host "- $_" -ForegroundColor Yellow
}

Write-Host "`nTo run the installation with these debug options, execute:" -ForegroundColor Cyan
Write-Host "irm https://win.templ.tech | iex`n" -ForegroundColor White

# Cleanup
Start-Sleep -Seconds 2  # Give processes time to release handles
Set-Location $env:USERPROFILE
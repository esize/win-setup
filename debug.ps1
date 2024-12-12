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

# Initialize debug configuration
$debugConfig = @{
    system = @{}
    debug = @{}
}

# Display menu
Write-Host "`n🔧 Windows Setup Debug Configuration`n" -ForegroundColor Cyan
Write-Host "Select debug options (space to toggle, enter when done):`n"

$selected = @{}
$currentOption = 0
$options = $debugOptions.Keys | Sort-Object

while ($true) {
    $options | ForEach-Object {
        $prefix = if ($_ -eq $options[$currentOption]) { ">" } else { " " }
        $status = if ($selected[$_]) { "[×]" } else { "[ ]" }
        $color = if ($_ -eq $options[$currentOption]) { "Cyan" } else { "White" }
        Write-Host "$prefix $status $_" -ForegroundColor $color
    }

    $key = $host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")

    # Clear menu
    $options | ForEach-Object { Write-Host "`r" }
    $options | ForEach-Object { Write-Host "`033[1A" }

    switch ($key.VirtualKeyCode) {
        38 { # Up arrow
            $currentOption = if ($currentOption -eq 0) { $options.Count - 1 } else { $currentOption - 1 }
        }
        40 { # Down arrow
            $currentOption = if ($currentOption -eq $options.Count - 1) { 0 } else { $currentOption + 1 }
        }
        32 { # Space
            $selected[$options[$currentOption]] = -not $selected[$options[$currentOption]]
        }
        13 { # Enter
            $done = $true
            break
        }
    }

    if ($done) { break }
}

# Build configuration from selections
$selected.Keys | Where-Object { $selected[$_] } | ForEach-Object {
    $option = $debugOptions[$_]
    $debugConfig[$option.category][$option.key] = $true
}

# Save configuration
$debugConfigPath = "$env:USERPROFILE\win-setup-debug.json"
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
Remove-Item -Path $setupDir -Recurse -Force -ErrorAction SilentlyContinue 
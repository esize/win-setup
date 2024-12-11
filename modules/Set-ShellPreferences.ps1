function Set-ShellPreferences {
    [CmdletBinding()]
    param()

    $settings = Get-Content "$scriptPath\config\settings.json" | ConvertFrom-Json

    # Helper function to ensure registry path exists
    function Ensure-RegistryPath {
        param([string]$Path)
        if (-not (Test-Path $Path)) {
            New-Item -Path $Path -Force | Out-Null
        }
    }

    # Helper function to safely set registry property
    function Set-RegistryProperty {
        param(
            [string]$Path,
            [string]$Name,
            [object]$Value
        )
        try {
            Ensure-RegistryPath -Path $Path
            Set-ItemProperty -Path $Path -Name $Name -Value $Value -ErrorAction Stop
        }
        catch {
            Write-Log "Failed to set registry property $Name at $Path : $_" -Level Warning
        }
    }

    # Taskbar alignment
    if ($settings.shell.taskbarBehavior.alignment -eq "center") {
        Set-RegistryProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced" -Name "TaskbarAl" -Value 1
    } else {
        Set-RegistryProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced" -Name "TaskbarAl" -Value 0
    }

    # Hide task view button
    if (-not $settings.shell.taskbarItems.taskView) {
        Set-RegistryProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced" -Name "ShowTaskViewButton" -Value 0
    }

    # Hide widgets button
    if (-not $settings.shell.taskbarItems.widgets) {
        try {
            Write-Log "Disabling Taskbar Widgets..."
            # Create the registry path if it doesn't exist
            $registryPath = "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced"
            if (-not (Test-Path $registryPath)) {
                New-Item -Path $registryPath -Force | Out-Null
            }
            
            # Attempt to set the registry value
            Set-ItemProperty -Path $registryPath -Name "TaskbarDa" -Value 0 -ErrorAction Stop
        }
        catch [System.Security.SecurityException] {
            Write-Log "Unable to disable Taskbar Widgets due to a Security Exception" -Level Warning
        }
        catch [System.Management.Automation.ItemNotFoundException] {
            Write-Log $_.Exception.ErrorRecord -Level Warning
        }
        catch {
            Write-Log "Unable to disable Taskbar Widgets due to unhandled exception" -Level Warning
            Write-Log $_.Exception.StackTrace -Level Debug
        }
    }

    # Search icon settings
    if ($settings.shell.taskbarItems.search -eq "icon") {
        Set-RegistryProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Search" -Name "SearchboxTaskbarMode" -Value 1
    }

    # Taskbar behavior settings
    $taskbarBehavior = $settings.shell.taskbarBehavior
    
    # Auto-hide taskbar
    Set-RegistryProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced" -Name "AutoHideTaskbar" -Value ([int]$taskbarBehavior.autoHide)
    
    # Show taskbar on all displays
    Set-RegistryProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced" -Name "MMTaskbarEnabled" -Value ([int]$taskbarBehavior.showOnAllDisplays)
    
    # Combine taskbar buttons
    $combineValue = switch ($taskbarBehavior.combineButtons) {
        "always" { 0 }
        "whenFull" { 1 }
        "never" { 2 }
    }
    Set-RegistryProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced" -Name "TaskbarGlomLevel" -Value $combineValue

    # Restart Explorer to apply changes
    try {
        Stop-Process -Name explorer -Force -ErrorAction SilentlyContinue
        Start-Process explorer
    }
    catch {
        Write-Log "Failed to restart Explorer: $_" -Level Warning
    }
} 

function Set-TaskbarPinnedApps {
    [CmdletBinding()]
    param()

    Write-Log "Configuring taskbar pinned applications..."

    # Define apps in desired order
    $pinnedApps = @(
        @{
            Name = "Windows Terminal"
            Path = "shell:AppsFolder\Microsoft.WindowsTerminal_8wekyb3d8bbwe!App"
        },
        @{
            Name = "Google Chrome"
            Path = "shell:AppsFolder\Chrome"
        },
        @{
            Name = "File Explorer"
            Path = "shell:AppsFolder\windows.immersivecontrolpanel_cw5n1h2txyewy!Microsoft.Windows.Explorer"
        },
        @{
            Name = "Obsidian"
            Path = "shell:AppsFolder\Obsidian"
        }
    )

    # Registry path for taskbar pins
    $taskbarPinPath = "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Taskband"

    # Clear existing pinned items
    Remove-Item -Path "$taskbarPinPath\Favorites" -Force -ErrorAction SilentlyContinue
    New-Item -Path "$taskbarPinPath\Favorites" -Force | Out-Null

    # Pin each app in order
    foreach ($app in $pinnedApps) {
        try {
            Write-Log "Pinning $($app.Name) to taskbar..."
            $shell = New-Object -ComObject Shell.Application
            $folder = $shell.Namespace($app.Path)
            $item = $folder.Self
            $verb = $item.Verbs() | Where-Object { $_.Name -match 'Pin to taskbar' }
            if ($verb) {
                $verb.DoIt()
            }
        }
        catch {
            Write-Log "Failed to pin $($app.Name): $_" -Level Warning
        }
    }

    # Restart Explorer to apply changes
    Write-Log "Restarting Explorer to apply changes..."
    Stop-Process -Name explorer -Force
    Start-Process explorer
}
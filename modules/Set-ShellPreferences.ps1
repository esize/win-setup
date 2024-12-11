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
        Set-RegistryProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced" -Name "TaskbarDa" -Value 0
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
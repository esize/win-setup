function Set-ShellPreferences {
    [CmdletBinding()]
    param()

    $settings = Get-Content "$scriptPath\config\settings.json" | ConvertFrom-Json

    # Taskbar alignment
    if ($settings.shell.taskbarBehavior.alignment -eq "center") {
        Set-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced" -Name "TaskbarAl" -Value 1
    } else {
        Set-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced" -Name "TaskbarAl" -Value 0
    }

    # Hide task view button
    if (-not $settings.shell.taskbarItems.taskView) {
        Set-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced" -Name "ShowTaskViewButton" -Value 0
    }

    # Hide widgets button
    if (-not $settings.shell.taskbarItems.widgets) {
        Set-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced" -Name "TaskbarDa" -Value 0
    }

    # Search icon settings
    if ($settings.shell.taskbarItems.search -eq "icon") {
        Set-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Search" -Name "SearchboxTaskbarMode" -Value 1
    }

    # Taskbar behavior settings
    $taskbarBehavior = $settings.shell.taskbarBehavior
    
    # Auto-hide taskbar
    Set-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced" -Name "AutoHideTaskbar" -Value ([int]$taskbarBehavior.autoHide)
    
    # Show taskbar on all displays
    Set-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced" -Name "MMTaskbarEnabled" -Value ([int]$taskbarBehavior.showOnAllDisplays)
    
    # Combine taskbar buttons
    $combineValue = switch ($taskbarBehavior.combineButtons) {
        "always" { 0 }
        "whenFull" { 1 }
        "never" { 2 }
    }
    Set-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced" -Name "TaskbarGlomLevel" -Value $combineValue

    # Restart Explorer to apply changes
    Stop-Process -Name explorer -Force
    Start-Process explorer
} 
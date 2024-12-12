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

    # Disable widgets button
    if (-not $settings.shell.taskbarItems.widgets) {
        try {
            Write-Log "Disabling Taskbar Widgets..."
            
            # Primary method using policy keys
            $policies = @(
                @{
                    Path = "HKLM:\SOFTWARE\Policies\Microsoft\Dsh"
                    Name = "AllowNewsAndInterests"
                    Value = 0
                },
                @{
                    Path = "HKLM:\SOFTWARE\Policies\Microsoft\Windows\Windows Feeds"
                    Name = "EnableFeeds"
                    Value = 0
                }
            )

            foreach ($policy in $policies) {
                try {
                    if (-not (Test-Path $policy.Path)) {
                        New-Item -Path $policy.Path -Force -ErrorAction Stop | Out-Null
                    }
                    Set-ItemProperty -Path $policy.Path -Name $policy.Name -Value $policy.Value -Type DWord -ErrorAction Stop
                }
                catch {
                    Write-Log "Note: Could not set policy at $($policy.Path) - this is expected on some systems" -Level Debug
                }
            }

            # User preferences method - with error handling
            $userSettings = @(
                @{
                    Path = "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced"
                    Name = "TaskbarDa"
                    Value = 0
                }
            )

            foreach ($setting in $userSettings) {
                try {
                    Ensure-RegistryPath -Path $setting.Path
                    Set-ItemProperty -Path $setting.Path -Name $setting.Name -Value $setting.Value -ErrorAction Stop
                }
                catch {
                    Write-Log "Could not set user preference $($setting.Name) - this is not critical" -Level Warning
                    # Continue execution even if this fails
                }
            }

            # Additional registry modification as fallback
            try {
                reg.exe add "HKCU\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced" /v TaskbarDa /t REG_DWORD /d 0 /f | Out-Null
            }
            catch {
                Write-Log "Fallback method for disabling widgets failed - manual configuration may be required" -Level Warning
            }
        }
        catch {
            Write-Log "Unable to fully disable Taskbar Widgets. Some settings may require manual configuration." -Level Warning
            Write-Log $_.Exception.Message -Level Debug
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
    Restart-Explorer
}

function Set-TaskbarPinnedApps {
    [CmdletBinding()]
    param()

    Write-Log "Configuring taskbar pinned apps..."

    # Define apps in desired order
    $pinnedApps = @(
        @{
            Name = "Windows Terminal"
            Path = "shell:AppsFolder\Microsoft.WindowsTerminal_8wekyb3d8bbwe!App"
        },
        @{
            Name = "Google Chrome"
            Path = "${env:ProgramFiles}\Google\Chrome\Application\chrome.exe"
        },
        @{
            Name = "File Explorer"
            Path = "explorer.exe"
        },
        @{
            Name = "Obsidian"
            Path = "${env:LocalAppData}\Obsidian\Obsidian.exe"
        }
    )

    try {
        # Create the required PowerShell script
        $scriptContent = @'
$Shell = New-Object -ComObject Shell.Application
$Desktop = $Shell.NameSpace('shell:::{B4BFCC3A-DB2C-424C-B029-7FE99A87C641}')

function Pin-ToTaskbar([string]$path) {
    $folder = Split-Path $path
    $file = Split-Path $path -Leaf
    
    if ($path.StartsWith("shell:")) {
        $item = $Shell.NameSpace($path).Self
    } else {
        $item = $Shell.NameSpace($folder).ParseName($file)
    }
    
    if ($item) {
        $item.InvokeVerb('taskbarpin')
    }
}

$paths = $args[0] -split ';'
foreach ($path in $paths) {
    if (Test-Path $path -PathType Leaf) {
        Pin-ToTaskbar $path
    }
}
'@

        # Save the script to a temporary file
        $tempScript = [System.IO.Path]::GetTempFileName() + ".ps1"
        $scriptContent | Out-File -FilePath $tempScript -Encoding UTF8

        # Build the paths string
        $validPaths = $pinnedApps.Path | Where-Object { $_.StartsWith("shell:") -or (Test-Path $_) }
        $pathsString = $validPaths -join ';'

        # Execute the script with elevated privileges
        Start-Process powershell.exe -ArgumentList "-NoProfile -ExecutionPolicy Bypass -File `"$tempScript`" `"$pathsString`"" -Verb RunAs -Wait

        # Cleanup
        Remove-Item $tempScript -Force -ErrorAction SilentlyContinue

        Write-Log "Taskbar apps configured successfully!"
    }
    catch {
        Write-Log "Failed to configure taskbar apps: $_" -Level Warning
    }
}
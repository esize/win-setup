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
                        New-Item -Path $policy.Path -Force | Out-Null
                    }
                    Set-ItemProperty -Path $policy.Path -Name $policy.Name -Value $policy.Value -Type DWord -ErrorAction Stop
                }
                catch {
                    Write-Log "Note: Could not set policy at $($policy.Path) - this is expected on some systems" -Level Debug
                }
            }

            # User preferences method
            $userSettings = @(
                @{
                    Path = "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced"
                    Name = "TaskbarDa"
                    Value = 0
                },
                @{
                    Path = "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced"
                    Name = "ShowTaskViewButton"
                    Value = 0
                }
            )

            foreach ($setting in $userSettings) {
                Set-RegistryProperty -Path $setting.Path -Name $setting.Name -Value $setting.Value
            }

            # Additional direct registry modification as final step
            if (-not (Get-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced" -Name "TaskbarDa" -ErrorAction SilentlyContinue)) {
                reg.exe add "HKCU\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced" /v TaskbarDa /t REG_DWORD /d 0 /f | Out-Null
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

    # Install required applications first
    Write-Log "Installing Google Chrome..."
    Install-Application -appId Google.Chrome

    Write-Log "Installing Obsidian..."
    Install-Application -appId Obsidian.Obsidian

    # Wait a moment for installations to complete
    Start-Sleep -Seconds 5

    # Define apps in desired order
    $pinnedApps = @(
        @{
            Name = "Windows Terminal"
            AppUserModelID = "Microsoft.WindowsTerminal_8wekyb3d8bbwe!App"
        },
        @{
            Name = "Google Chrome"
            AppUserModelID = "Chrome"
            ExePath = "${env:ProgramFiles}\Google\Chrome\Application\chrome.exe"
        },
        @{
            Name = "File Explorer"
            AppUserModelID = "Microsoft.Windows.Explorer"
            ExePath = "explorer.exe"
        },
        @{
            Name = "Obsidian"
            AppUserModelID = "Obsidian"
            ExePath = "${env:LocalAppData}\Obsidian\Obsidian.exe"
        }
    )

    # Load required assemblies
    Add-Type -AssemblyName System.Runtime.WindowsRuntime
    $asTaskGeneric = ([System.WindowsRuntimeSystemExtensions].GetMethods() | Where-Object { $_.Name -eq 'AsTask' -and $_.GetParameters().Count -eq 1 -and $_.GetParameters()[0].ParameterType.Name -eq 'IAsyncOperation`1' })[0]

    # Get package manager
    $packageManager = [Windows.Management.Deployment.PackageManager, Windows.Management.Deployment, ContentType = WindowsRuntime]::new()

    foreach ($app in $pinnedApps) {
        try {
            Write-Log "Pinning $($app.Name) to taskbar..."
            
            # Try UWP app first
            try {
                $package = $packageManager.FindPackagesForUser("", $app.AppUserModelID)
                if ($package) {
                    (New-Object -ComObject Shell.Application).PinToTaskbar($package.InstalledLocation.Path)
                    continue
                }
            } catch {
                # Continue to traditional exe pinning if UWP approach fails
            }

            # Traditional exe pinning
            if ($app.ExePath -and (Test-Path $app.ExePath)) {
                $shell = New-Object -ComObject Shell.Application
                $folder = $shell.Namespace([System.IO.Path]::GetDirectoryName($app.ExePath))
                $item = $folder.ParseName([System.IO.Path]::GetFileName($app.ExePath))
                if ($item) {
                    $item.InvokeVerb('taskbarpin')
                }
            }
        }
        catch {
            Write-Log "Failed to pin $($app.Name): $_" -Level Warning
        }
    }

    # Restart Explorer to apply changes
    Restart-Explorer
}
}
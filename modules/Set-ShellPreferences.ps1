function Set-ShellPreferences {
    [CmdletBinding()]
    param()

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
            Write-WarningLog "Failed to set registry property $Name at $Path : $_"
        }
    }

    # Center taskbar
    Set-RegistryProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced" -Name "TaskbarAl" -Value 1

    # Hide task view button
    Set-RegistryProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced" -Name "ShowTaskViewButton" -Value 0

    # Disable widgets
    Write-VerboseLog "Disabling Taskbar Widgets..."
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
        Set-RegistryProperty -Path $policy.Path -Name $policy.Name -Value $policy.Value
    }

    # Configure taskbar pinned apps
    Set-TaskbarPinnedApps
}

function Set-TaskbarPinnedApps {
    [CmdletBinding()]
    param()

    Write-VerboseLog "Configuring taskbar pinned apps..."

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

        Write-SuccessLog "Taskbar apps configured successfully!"
    }
    catch {
        Write-WarningLog "Failed to configure taskbar apps: $_"
    }
}
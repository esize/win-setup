function Set-VisualPreferences {
    [CmdletBinding()]
    param()

    $settings = Get-Content "$scriptPath\config\settings.json" | ConvertFrom-Json

    # Configure desktop icons
    $desktopIconsPath = "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\HideDesktopIcons\NewStartPanel"
    if (-not (Test-Path $desktopIconsPath)) {
        New-Item -Path $desktopIconsPath -Force | Out-Null
    }

    # Desktop icon CLSIDs
    $desktopIcons = @{
        "ThisPC" = "{20D04FE0-3AEA-1069-A2D8-08002B30309D}"
        "UserFiles" = "{59031A47-3F72-44A7-89C5-5595FE6B30EE}"
        "Network" = "{F02C1A0D-BE21-4350-88B0-7367FC96EF3C}"
        "RecycleBin" = "{645FF040-5081-101B-9F08-00AA002F954E}"
        "ControlPanel" = "{5399E694-6CE5-4D6C-8FCE-1D8870FDCBA0}"
    }

    # Show only Recycle Bin by default
    foreach ($icon in $desktopIcons.GetEnumerator()) {
        $value = if ($icon.Key -eq "RecycleBin") { 0 } else { 1 }
        Set-ItemProperty -Path $desktopIconsPath -Name $icon.Value -Value $value -Type DWord
    }

    # Allow themes to change desktop icons
    Set-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Themes" -Name "ThemeChangesDesktopIcons" -Value 1 -Type DWord

    # Install and apply theme pack
    $themePath = "$scriptPath\theme.deskthemepack"
    if (Test-Path $themePath) {
        try {
            # Install theme by double-clicking (invoking) the theme pack
            Invoke-Item $themePath
            
            # Wait a moment for the theme to install
            Start-Sleep -Seconds 2
            
            # Get the installed theme path (usually in AppData)
            $installedThemePath = Get-ChildItem "$env:LocalAppData\Microsoft\Windows\Themes" |
                                Where-Object { $_.Name -like "*.theme" } |
                                Sort-Object LastWriteTime -Descending |
                                Select-Object -First 1 -ExpandProperty FullName
            
            if ($installedThemePath) {
                # Apply the theme
                Start-Process rundll32.exe -ArgumentList "shell32.dll,Control_RunDLL desk.cpl,,2" -Wait
                Set-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Themes" -Name "CurrentTheme" -Value $themePath
                $themeFound = $true
            }
        }
        catch {
            Write-Log "Failed to apply theme: $_" -Level Warning
            $themeFound = $false
        }
        
        if (-not $themeFound) {
            Write-Log "Glow theme file not found - falling back to default theme" -Level Warning
        }
    } else {
        Write-Log "Theme pack file not found at: $themePath" -Level Warning
    }

    # Apply cursor scheme
    if ($settings.visual.cursorScheme -eq "Windows Black") {
        $cursorPath = "HKCU:\Control Panel\Cursors"
        $blackCursorScheme = @{
            "Arrow"       = "%SystemRoot%\cursors\aero_arrow.cur"
            "Hand"        = "%SystemRoot%\cursors\aero_link.cur"
            "IBeam"       = "%SystemRoot%\cursors\beam_r.cur"
            "Wait"        = "%SystemRoot%\cursors\busy_r.cur"
            "SizeNWSE"    = "%SystemRoot%\cursors\size1_r.cur"
            "SizeNESW"    = "%SystemRoot%\cursors\size2_r.cur"
            "SizeWE"      = "%SystemRoot%\cursors\size3_r.cur"
            "SizeNS"      = "%SystemRoot%\cursors\size4_r.cur"
            "SizeAll"     = "%SystemRoot%\cursors\move_r.cur"
            "No"          = "%SystemRoot%\cursors\unavail_r.cur"
            "AppStarting" = "%SystemRoot%\cursors\working_r.cur"
            "Help"        = "%SystemRoot%\cursors\help_r.cur"
            "Scheme"      = "Windows Black"
        }

        foreach ($cursor in $blackCursorScheme.GetEnumerator()) {
            Set-ItemProperty -Path $cursorPath -Name $cursor.Key -Value $cursor.Value
        }

        # Refresh cursor settings
        $signature = @'
[DllImport("user32.dll", EntryPoint = "SystemParametersInfo")]
public static extern bool SystemParametersInfo(uint uiAction, uint uiParam, string pvParam, uint fWinIni);
'@
        $refresh = Add-Type -MemberDefinition $signature -Name WinAPI -Namespace SystemParamInfo -PassThru
        $refresh::SystemParametersInfo(0x0057, 0, $null, 0x01)
    }

    # Try to refresh the theme using alternative method
    try {
        # Load required assemblies
        Add-Type -AssemblyName System.Runtime.WindowsRuntime
        $asTaskGeneric = ([System.WindowsRuntimeSystemExtensions].GetMethods() | Where-Object { $_.Name -eq 'AsTask' -and $_.GetParameters().Count -eq 1 -and $_.GetParameters()[0].ParameterType.Name -eq 'IAsyncOperation`1' })[0]

        # Broadcast theme change message using SendMessage API
        $signature = @'
        [DllImport("user32.dll", SetLastError=true, CharSet=CharSet.Auto)]
        public static extern IntPtr SendMessageTimeout(
            IntPtr hWnd, 
            uint Msg, 
            UIntPtr wParam, 
            string lParam, 
            uint fuFlags, 
            uint uTimeout, 
            out UIntPtr lpdwResult
        );
'@

        # Add the type if it doesn't exist
        if (-not ("Win32.NativeMethods" -as [type])) {
            Add-Type -MemberDefinition $signature -Name NativeMethods -Namespace Win32 -ErrorAction SilentlyContinue
        }

        # Notify all windows of the theme change
        [UIntPtr]$result = [UIntPtr]::Zero
        [Win32.NativeMethods]::SendMessageTimeout(
            [IntPtr]0xFFFF, # HWND_BROADCAST
            0x001A,         # WM_SETTINGCHANGE
            [UIntPtr]::Zero,
            "ImmersiveColorSet",
            2,              # SMTO_ABORTIFHUNG
            5000,           # 5 second timeout
            [ref]$result
        ) | Out-Null

        Write-Log "Theme refresh completed successfully" -Level Information
    }
    catch {
        Write-Log "Non-critical error while refreshing theme: $_" -Level Warning
    }
} 
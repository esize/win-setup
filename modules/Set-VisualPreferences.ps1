function Set-VisualPreferences {
    [CmdletBinding()]
    param()

    $settings = Get-Content "$scriptPath\config\settings.json" | ConvertFrom-Json

    # Install and apply theme pack
    $themePath = "$scriptPath\theme.deskthemepack"
    $themesDirectory = "$env:LocalAppData\Microsoft\Windows\Themes"
    
    if (Test-Path $themePath) {
        try {
            # Ensure themes directory exists
            if (-not (Test-Path $themesDirectory)) {
                New-Item -ItemType Directory -Path $themesDirectory -Force | Out-Null
            }

            # Copy theme to Windows themes directory
            $destinationPath = Join-Path $themesDirectory "CustomTheme.deskthemepack"
            Copy-Item -Path $themePath -Destination $destinationPath -Force
            
            # Apply theme directly through registry
            $themeName = [System.IO.Path]::GetFileNameWithoutExtension($destinationPath)
            $themeRegPath = "HKCU:\Software\Microsoft\Windows\CurrentVersion\Themes"
            $personalizedThemePath = Join-Path $themesDirectory "$themeName.theme"

            # Copy theme files
            Copy-Item -Path $themePath -Destination $destinationPath -Force

            # Set theme registry keys
            Set-ItemProperty -Path $themeRegPath -Name "CurrentTheme" -Value $personalizedThemePath
            Set-ItemProperty -Path $themeRegPath -Name "ThemeChangesDesktopIcons" -Value 1
            Set-ItemProperty -Path $themeRegPath -Name "ThemeChangesMousePointers" -Value 1
            Set-ItemProperty -Path $themeRegPath -Name "ThemeChangesDesktopBackgroundColor" -Value 1

            # Refresh the theme
            try {
                # Try to refresh the theme using alternative method
                $signature = @'
[DllImport("UXTheme.dll", SetLastError = true, CharSet = CharSet.Unicode)]
public static extern int RefreshImmersiveColorPolicyState();
'@

                if (-not ("Win32Functions.UXTheme" -as [type])) {
                    Add-Type -MemberDefinition $signature -Name UXTheme -Namespace Win32Functions -ErrorAction SilentlyContinue
                }

                # Attempt to refresh theme, but don't throw if it fails
                try {
                    [Win32Functions.UXTheme]::RefreshImmersiveColorPolicyState()
                }
                catch {
                    Write-Log "Could not refresh theme using UXTheme.dll - this is not critical" -Level Warning
                }

                # Broadcast system-wide theme change message
                $CSharpSig = @'
[DllImport("user32.dll", SetLastError=true, CharSet=CharSet.Auto)]
public static extern IntPtr SendMessageTimeout(IntPtr hWnd, uint Msg, UIntPtr wParam, string lParam, uint fuFlags, uint uTimeout, out UIntPtr lpdwResult);
'@

                if (-not ("Win32Functions.User32" -as [type])) {
                    Add-Type -MemberDefinition $CSharpSig -Name User32 -Namespace Win32Functions -ErrorAction SilentlyContinue
                }

                # Notify all windows of theme change
                [Win32Functions.User32]::SendMessageTimeout(0xFFFF, 0x001A, [UIntPtr]::Zero, "ImmersiveColorSet", 2, 5000, [ref][UIntPtr]::Zero) | Out-Null
            }
            catch {
                Write-Log "Non-critical error while refreshing theme: $_" -Level Warning
            }
        }
        catch {
            Write-Log "Failed to apply theme: $_" -Level Error
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
} 
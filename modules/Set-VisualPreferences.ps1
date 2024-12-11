function Set-VisualPreferences {
    [CmdletBinding()]
    param()

    $settings = Get-Content "$scriptPath\config\settings.json" | ConvertFrom-Json

    # Apply Windows theme
    if ($settings.visual.theme -eq "Glow") {
        # Path to the Glow theme file
        $themePath = "$env:SystemRoot\Resources\Themes\Glow.theme"
        if (Test-Path $themePath) {
            Start-Process rundll32.exe -ArgumentList "shell32.dll,Control_RunDLL desk.cpl,,2" -Wait
            Set-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Themes" -Name "CurrentTheme" -Value $themePath
        }
        else {
            Write-Log "Glow theme file not found" -Level Warning
        }
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
function Set-VisualPreferences {
    [CmdletBinding()]
    param()

    $settings = Get-Content "$scriptPath\config\settings.json" | ConvertFrom-Json

    Write-Log "Configuring visual preferences..."

    try {
        # Load required assemblies for visual styles
        Add-Type -TypeDefinition @"
            using System;
            using System.Runtime.InteropServices;

            public class VisualStyles {
                [DllImport("uxtheme.dll", CharSet = CharSet.Unicode)]
                public static extern int SetSystemVisualStyle(string pszThemeFile, string pszColorName, string pszSizeName, int dwFlags);
            }
"@

        # Configure transparency effects
        if ($settings.visual.transparency) {
            Set-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Themes\Personalize" -Name "EnableTransparency" -Value 1
        } else {
            Set-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Themes\Personalize" -Name "EnableTransparency" -Value 0
        }

        # Configure snap window features
        Set-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced" -Name "EnableSnapAssistFlyout" -Value ([int]$settings.visual.snapAssistFlyout)
        Set-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced" -Name "SnapAssist" -Value ([int]$settings.visual.snapAssistSuggestions)
        
        # Configure mouse settings
        if (-not $settings.visual.mouseAcceleration) {
            Set-ItemProperty -Path "HKCU:\Control Panel\Mouse" -Name "MouseSpeed" -Value "0"
            Set-ItemProperty -Path "HKCU:\Control Panel\Mouse" -Name "MouseThreshold1" -Value "0"
            Set-ItemProperty -Path "HKCU:\Control Panel\Mouse" -Name "MouseThreshold2" -Value "0"
        }

        Write-Log "Visual preferences configured successfully!"
    }
    catch {
        Write-Log "Failed to configure visual preferences: $_" -Level Error
        # Continue execution even if visual styles fail
    }
} 
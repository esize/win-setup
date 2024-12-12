function Set-TerminalPreferences {
    [CmdletBinding()]
    param()

    Write-Log -Level INFO "Configuring Windows Terminal preferences..."

    $terminalSettingsPath = "$env:LOCALAPPDATA\Packages\Microsoft.WindowsTerminal_8wekyb3d8bbwe\LocalState\settings.json"
    $terminalDefaultsPath = "$env:LOCALAPPDATA\Packages\Microsoft.WindowsTerminal_8wekyb3d8bbwe\LocalState\defaults.json"

    # Create the terminal settings object
    $terminalSettings = @{
        '$help' = 'https://aka.ms/terminal-documentation'
        '$schema' = 'https://aka.ms/terminal-profiles-schema'
        'copyFormatting' = 'none'
        'copyOnSelect' = $false
        'defaultProfile' = '{574e775e-4f2a-5b96-ac1e-a2962a402336}' # PowerShell
        'useAcrylicInTabRow' = $true
        'windowingBehavior' = 'useAnyExisting'
        'actions' = @(
            @{
                'command' = 'unbound'
                'keys' = 'ctrl+v'
            }
            @{
                'command' = @{
                    'action' = 'copy'
                    'singleLine' = $false
                }
                'keys' = 'ctrl+c'
            }
            @{
                'command' = 'paste'
            }
            @{
                'command' = @{
                    'action' = 'splitPane'
                    'split' = 'auto'
                    'splitMode' = 'duplicate'
                }
                'keys' = 'alt+shift+d'
            }
            @{
                'command' = 'find'
                'keys' = 'ctrl+shift+f'
            }
        )
        'profiles' = @{
            'defaults' = @{
                'colorScheme' = 'Catppuccin Macchiato'
                'cursorShape' = 'bar'
                'font' = @{
                    'face' = 'GeistMono Nerd Font Mono'
                    'fallback' = @('Cascadia Mono', 'Consolas')
                }
                'opacity' = 90
                'useAcrylic' = $false
            }
        }
        'schemes' = @(
            @{
                'name' = 'Catppuccin Macchiato'
                'background' = '#24273A'
                'foreground' = '#CAD3F5'
                'cursorColor' = '#F4DBD6'
                'selectionBackground' = '#5B6078'
                'black' = '#494D64'
                'brightBlack' = '#5B6078'
                'blue' = '#8AADF4'
                'brightBlue' = '#8AADF4'
                'cyan' = '#8BD5CA'
                'brightCyan' = '#8BD5CA'
                'green' = '#A6DA95'
                'brightGreen' = '#A6DA95'
                'purple' = '#F5BDE6'
                'brightPurple' = '#F5BDE6'
                'red' = '#ED8796'
                'brightRed' = '#ED8796'
                'white' = '#B8C0E0'
                'brightWhite' = '#A5ADCB'
                'yellow' = '#EED49F'
                'brightYellow' = '#EED49F'
            }
        )
        'themes' = @(
            @{
                'name' = 'Catppuccin Macchiato'
                'tab' = @{
                    'background' = '#24273AFF'
                    'iconStyle' = 'default'
                    'showCloseButton' = 'always'
                    'unfocusedBackground' = $null
                }
                'tabRow' = @{
                    'background' = '#1E2030FF'
                    'unfocusedBackground' = '#181926FF'
                }
                'window' = @{
                    'applicationTheme' = 'dark'
                    'experimental.rainbowFrame' = $false
                    'useMica' = $false
                }
            }
        )
    }

    try {
        # Ensure the directory exists
        $settingsDir = Split-Path $terminalSettingsPath -Parent
        if (-not (Test-Path $settingsDir)) {
            New-Item -ItemType Directory -Path $settingsDir -Force | Out-Null
        }

        # Convert and save the settings
        $terminalSettings | ConvertTo-Json -Depth 10 | Set-Content $terminalSettingsPath -Force
        Write-Log -Level INFO "Windows Terminal settings configured successfully!"
    }
    catch {
        Write-Log -Level ERROR "Failed to configure Windows Terminal: $_"
        throw
    }
} 
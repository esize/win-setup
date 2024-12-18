# Windows Setup Script

Automated Windows 11 configuration script that sets up your development environment.

## Features

- Installs common applications via winget
- Configures Windows system preferences
- Sets up WSL2 with Ubuntu
- Configures visual preferences and themes
- Customizes taskbar and Start Menu
- Sets up developer environment

## Prerequisites

- Windows 11
- PowerShell 5.1 or later
- Administrator privileges

## Installation

Run the following command in PowerShell (Admin):

```PowerShell
irm https://win.templ.tech | iex
```

For development and testing, you can run the script in debug mode:

```PowerShell
irm https://win.templ.tech/debug | iex
```

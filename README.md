# mysetup

A Windows setup and configuration toolkit.

## Prerequisites

- Windows 11
- PowerShell 7+ (Recommended, but Windows PowerShell 5.1 is also supported)

## Quick Start

1. Clone this repository

2. Open PowerShell as a standard user (non-admin)

3. Set execution policy to allow scripts:

```powershell
Set-ExecutionPolicy Unrestricted -Scope CurrentUser
```

4. Unblock downloaded files:

```powershell
dir -Path . -Recurse | Unblock-File
```

5. Run the setup script:

```powershell
powershell -ExecutionPolicy bypass win\setup.ps1
```

## What's Included

- **Package Management**: Scoop, pip, gsudo
- **PowerShell Configuration**:
    - Unified profile for Windows PowerShell 5.1 and PowerShell 7+ (pwsh)
    - Oh-My-Posh theme engine integration
    - Custom modular architecture (GitTools, UtilityTools, etc.)
- **Development Tools**:
    - Git configuration with aliases
    - VS Code extensions and settings sync
    - Windows Terminal customization
- **System Configuration**:
    - WSL2 settings
    - Windows Explorer tweaks
    - Aria2 download manager integration

## Configuration Files

The setup script creates symbolic links for:

- **PowerShell Profile**: Links to both `$PROFILE` (v5.1) and `$PROFILE.CurrentUserCurrentHost` (v7+)
- **Git Config**: Links global `.gitconfig`
- **Windows Terminal**: Links `settings.json`
- **VS Code**: Links `settings.json` and installs extensions
- **WSL**: Links `.wslconfig`

## Modular Architecture

The PowerShell profile is built on a modular system. You can control which modules are loaded by editing your local profile:

`~\profile.local.ps1`:
```powershell
$importModules = @{
    "GitTools"     = $true   # Enable Git helpers
    "UtilityTools" = $true   # Enable general utilities
    "LookerTools"  = $false  # Disable Looker tools
}
```

## Notes

- **Run as Non-Admin**: The setup script must be run as a standard user. It will automatically request elevation (via gsudo) only when necessary.
- **PowerShell Support**: Fully supports both Windows PowerShell 5.1 and PowerShell 7 (pwsh).
- **Restart Required**: Some settings (like environment variables) require a new shell session or system restart to take effect.

## License

This project is licensed under the GNU General Public License v3.0 - see the LICENSE file for details.
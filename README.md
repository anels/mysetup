# mysetup

A Windows setup and configuration toolkit.

## Prerequisites

- Windows 11
- PowerShell 7+ (recommended)

## Quick Start

1. Clone this repository

2. Run PowerShell as non-admin and execute:

```
Set-ExecutionPolicy Unrestricted
```

3. Unblock downloaded files:

```
dir -Path . -Recurse | Unblock-File
```

4. Run the setup script:

```
powershell
powershell -ExecutionPolicy bypass win\setup.ps1
```

## What's Included

- PowerShell configuration
- Git configuration
- Windows Terminal settings
- VSCode settings and extensions
- WSL2 configuration
- Windows Explorer tweaks
- Aria2 download manager config

## Configuration Files

The setup will create symbolic links for:

- PowerShell profile
- Git config (.gitconfig)
- Windows Terminal settings
- WSL config (.wslconfig)
- Editor config (.editorconfig)
- VSCode settings

## Notes

- Run the setup script as non-admin (the script will elevate privileges when needed)
- Some settings may require a system restart to take effect
- WSL2 settings require Windows 11 Build 19041 or later

## License

This project is licensed under the GNU General Public License v3.0 - see the LICENSE file for details.
# mysetup

A cross-platform (macOS and Windows) environment setup and configuration toolkit, focusing on a DRY architecture, declarative package management, and safe symlinking.

## Project Structure

- `common/`: Shared configuration files (e.g., VS Code settings, global Git aliases) applied to both platforms.
- `mac/`: macOS specific setup script (`setup.sh`), dotfiles, and `Brewfile`.
- `win/`: Windows specific setup script (`setup.ps1`), PowerShell profiles, and Windows Terminal configs.

## Prerequisites

### Windows
- Windows 11
- PowerShell 7+ (Recommended, standard Windows PowerShell 5.1 also supported)
- *Recommended:* Developer Mode enabled (allows standard users to create symlinks without `gsudo` elevation).

### macOS
- Terminal with `bash` or `zsh` installed.
- Requires standard user privileges (do not run as root).

## Quick Start

### Windows

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

### macOS

1. Clone this repository
2. Open your terminal as a standard user.
3. Run the setup script:
   ```bash
   bash mac/setup.sh
   ```

## Key Features

- **Unified Configuration**: DRY approach. VS Code settings and global `.gitconfig` alias features are shared across both environments via the `common/` folder.
- **Declarative Packages**: macOS uses a `Brewfile` (Homebrew Bundle), while Windows uses Scoop and pip.
- **Safe Symlinks**: Automatic backup mechanism. If a target config file already exists, it is renamed with a timestamp backup (e.g., `settings.backup_20260326_120000`) before creating the symlink, preventing data loss.
- **Windows Developer Mode Integration**: If Windows 11 Developer Mode is enabled, symlinks are created seamlessly without triggering UAC / `gsudo` elevation prompts.
- **Modular Shell Profiles**: 
    - Windows uses a modular `.psm1` architecture, manageable via `profile.local.ps1`.
    - macOS loads an environment-specific `.zshrc.local`.
    - Both platforms generate these local environment files securely from `.template` files during the initial setup.

## Configuration Files

The setup scripts securely back up your existing files before creating symbolic links for:
- **Git Config**: OS-specific `.gitconfig` with an `include` directive pointing to `common/git/.gitconfig`.
- **VS Code**: Links `settings.json` and installs extensions.
- **Terminal**: `settings.json` (Windows Terminal).
- **Shell Profiles**: Links `Microsoft.PowerShell_profile.ps1` (Windows) and `.zshrc` (macOS).

## Local Machine Settings

You can control environment variables and loadable modules per machine without dirtying the git working tree:

**Windows (`~\profile.local.ps1`) / macOS (`~/.zshrc.local`)**
These files are generated from templates on first run and allow you to toggle modules or store API keys securely.

## License

This project is licensed under the GNU General Public License v3.0 - see the LICENSE file for details.
# Check for admin privileges at start
[bool]$isAdmin = ([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)

if ($isAdmin) {
    Write-Host "Please run this script in non-admin" -ForegroundColor Yellow
    exit 0
}

# Helper Functions
class SetupHelper {
    static [bool] TestCommand([string]$cmdname) {
        return [bool](Get-Command -Name $cmdname -ErrorAction SilentlyContinue)
    }

    static [void] WriteInfo([string]$msg) {
        Write-Host "`n$msg`n------------------------------------" -ForegroundColor Green
    }

    static [void] SyncEnvVariables() {
        $Env:Path = [System.Environment]::GetEnvironmentVariable("Path", "Machine") + ";" +
                    [System.Environment]::GetEnvironmentVariable("Path", "User")
    }
}

# Improved symlink creation with error handling and validation
Function New-SoftLink {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory = $true)][ValidateNotNullOrEmpty()][string]$Source,
        [Parameter(Mandatory = $true)][ValidateNotNullOrEmpty()][string]$Target
    )

    try {
        if (!(Test-Path $Source)) {
            throw "Source path does not exist: $Source"
        }

        # Check if Dev Mode is enabled
        $devMode = $false
        try {
            $regKey = Get-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\AppModelUnlock" -Name "AllowDevelopmentWithoutDevLicense" -ErrorAction SilentlyContinue
            if ($regKey -and $regKey.AllowDevelopmentWithoutDevLicense -eq 1) {
                $devMode = $true
            }
        } catch {}

        if (Test-Path $Target) {
            $item = Get-Item $Target -Force
            if ($item.LinkType -eq 'SymbolicLink') {
                if ($devMode) { Remove-Item $Target -Force } else { gsudo Remove-Item $Target -Force }
            } else {
                $backupPath = "$Target.backup_$(Get-Date -f yyyyMMdd_HHmmss)"
                if ($devMode) { Rename-Item -Path $Target -NewName (Split-Path $backupPath -Leaf) -Force } else { gsudo Rename-Item -Path $Target -NewName (Split-Path $backupPath -Leaf) -Force }
                Write-Host "Backed up existing file to $backupPath" -ForegroundColor Yellow
            }
        }

        $targetDir = Split-Path -Parent $Target
        if (!(Test-Path $targetDir)) {
            New-Item -Path $targetDir -ItemType Directory -Force | Out-Null
        }

        $isDir = Test-Path -PathType Container $Source
        if ($devMode) {
            if ($isDir) { cmd.exe /c "mklink /D `"$Target`" `"$Source`" >nul 2>&1" } else { cmd.exe /c "mklink `"$Target`" `"$Source`" >nul 2>&1" }
        } else {
            if ($isDir) { gsudo cmd.exe /c "mklink /D `"$Target`" `"$Source`" >nul 2>&1" } else { gsudo cmd.exe /c "mklink `"$Target`" `"$Source`" >nul 2>&1" }
        }
        Write-Host "Created Soft link: $Target -> $Source" -ForegroundColor Green
    }
    catch {
        Write-Host "Failed to create symlink: $_" -ForegroundColor Red
    }
}

# Optimized package manager installation functions
Function Install-PackageManager {
    param (
        [Parameter(Mandatory = $true)][string]$Name,
        [Parameter(Mandatory = $true)][scriptblock]$InstallScript
    )

    if (-Not ([SetupHelper]::TestCommand($Name))) {
        [SetupHelper]::WriteInfo("Installing $Name...")
        & $InstallScript
        [SetupHelper]::SyncEnvVariables
    }
}

# Main setup execution with error handling
try {
    $ErrorActionPreference = "Stop"

    # Setup logging
    $logDir = Join-Path $PSScriptRoot "log"
    if (!(Test-Path $logDir)) { New-Item -Path $logDir -ItemType Directory | Out-Null }
    $logFile = Join-Path $logDir "setup_$(Get-Date -f yyyyMMddHHmmss).log"
    Start-Transcript -Path $logFile

    [SetupHelper]::WriteInfo("Starting Windows Setup Script v1.0")

    # Install package managers
    Install-PackageManager -Name "scoop" -InstallScript {
        Invoke-RestMethod get.scoop.sh | Invoke-Expression
        scoop install aria2 gsudo git

        # Configure scoop
        $scoopConfig = @{
            'show_update_log' = $false
            'aria2-enabled' = $true
            'aria2-split' = 32
            'aria2-max-connection-per-server' = 16
            'aria2-min-split-size' = '1M'
            'aria2-warning-enabled' = $false
            'aria2-options' = '-q'
        }

        foreach ($key in $scoopConfig.Keys) {
            scoop config $key $scoopConfig[$key]
        }
    }

    # Configure gsudo
    gsudo config LogLevel "Error" | Out-Null
    gsudo config CacheMode Auto

    # Install applications and configure system
    . $PSScriptRoot\apps\scoop.ps1
    . $PSScriptRoot\apps\pip.ps1

    # Setup VS Code if installed
    if ([SetupHelper]::TestCommand('code')) {
        [SetupHelper]::WriteInfo("Setting up VS Code...")
        . $PSScriptRoot\vscode\vscode.ps1
        New-SoftLink -Source "$PSScriptRoot\..\common\vscode\settings.json" -Target $Home\scoop\apps\vscode\current\data\user-data\User\settings.json
    }

    # Setup Windows Terminal
    [SetupHelper]::WriteInfo("Setting up Windows Terminal...")
    New-SoftLink -Source "$PSScriptRoot\windows-terminal\settings.json" -Target "$env:LOCALAPPDATA\Microsoft\Windows Terminal\settings.json"

    # Git configuration
    [SetupHelper]::WriteInfo("Setting up Git...")
    $gitConfigs = @{
        "include.path" = @(
            "$PSScriptRoot\dotfiles\.gitconfig",
            "$HOME\.gitconfig.local"
        )
        "safe.directory" = @("*")
    }

    foreach ($config in $gitConfigs.GetEnumerator()) {
        $existing = git config --global --get-all $config.Key
        foreach ($value in $config.Value) {
            if (($null -eq $existing) -or ($value -notin @($existing))) {
                git config --global --add $config.Key $value
            }
        }
    }

    # Dotfiles setup
    [SetupHelper]::WriteInfo("Setting up dotfiles...")

    # Create PowerShell profile directory if it doesn't exist
    $profileDir = Split-Path -Parent $PROFILE
    if (-not (Test-Path $profileDir)) {
        New-Item -ItemType Directory -Path $profileDir -Force | Out-Null
    }

    # Create profile.local.ps1 if it doesn't exist
    $localProfilePath = Join-Path $Home "profile.local.ps1"
    if (-not (Test-Path $localProfilePath)) {
        Write-Host "Creating profile.local.ps1..."
        $dotfilesModulesPath = Join-Path $PSScriptRoot "dotfiles\modules"
        $templatePath = Join-Path $PSScriptRoot "dotfiles\profile.local.template.ps1"
        if (Test-Path $templatePath) {
            $templateContent = Get-Content -Path $templatePath -Raw
            $templateContent = $templateContent -replace '\[DOTFILES_MODULES_PATH\]', $dotfilesModulesPath
            $templateContent | Out-File -FilePath $localProfilePath -Encoding UTF8
            Write-Host "Created profile.local.ps1 at: $localProfilePath from template" -ForegroundColor Green
        }
    } else {
        Write-Host "profile.local.ps1 already exists at: $localProfilePath" -ForegroundColor Yellow
    }

    # Create symbolic links for modules
    $sourceModulesDir = Join-Path "$PSScriptRoot\dotfiles" "modules"
    $modulesDir = Join-Path (Split-Path -Parent $PROFILE) "modules"
    if (Test-Path $sourceModulesDir) {
        if (-not (Test-Path $modulesDir)) {
            New-Item -Path $modulesDir -ItemType Directory -Force | Out-Null
        }
        Get-ChildItem -Path $sourceModulesDir -Filter "*.psm1" | ForEach-Object {
            New-SoftLink -Source $_.FullName -Target (Join-Path $modulesDir $_.Name)
        }
    }

    # Create symbolic link for terminal tools cheatsheet (next to profile so $PSScriptRoot resolves it)
    $sourceCheatsheet = Join-Path $PSScriptRoot "terminal-tools-cheatsheet.md"
    if (Test-Path $sourceCheatsheet) {
        New-SoftLink -Source $sourceCheatsheet -Target (Join-Path $profileDir "terminal-tools-cheatsheet.md")
    }

    # Create symbolic link for PowerShell profile
    $sourceProfile = Join-Path "$PSScriptRoot\dotfiles" "Microsoft.PowerShell_profile.ps1"
    if (Test-Path $sourceProfile) {
        # Create symlink for Windows PowerShell 5.1
        New-SoftLink -Source $sourceProfile -Target $PROFILE

        # Create symlink for PowerShell 7+ (pwsh) if installed
        if ([SetupHelper]::TestCommand('pwsh')) {
            # Get pwsh profile path (different from Windows PowerShell)
            # Use single quotes so pwsh evaluates $PROFILE in its own context, not execute it
            $pwshProfilePath = pwsh -NoProfile -Command '$PROFILE'

            if ($pwshProfilePath -and $pwshProfilePath -ne $PROFILE) {
                # Create pwsh profile directory if needed
                $pwshProfileDir = Split-Path -Parent $pwshProfilePath
                if (-not (Test-Path $pwshProfileDir)) {
                    New-Item -ItemType Directory -Path $pwshProfileDir -Force | Out-Null
                }

                # Delete existing profile if it's not a symlink or points wrong
                if (Test-Path $pwshProfilePath) {
                    $item = Get-Item $pwshProfilePath -Force
                    if ($item.LinkType -ne 'SymbolicLink' -or $item.Target -ne $sourceProfile) {
                        try {
                            $devModeKey = Get-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\AppModelUnlock" -Name "AllowDevelopmentWithoutDevLicense" -ErrorAction SilentlyContinue
                            if ($devModeKey -and $devModeKey.AllowDevelopmentWithoutDevLicense -eq 1) {
                                Remove-Item $pwshProfilePath -Force
                            } else {
                                gsudo Remove-Item $pwshProfilePath -Force
                            }
                        } catch {
                            gsudo Remove-Item $pwshProfilePath -Force
                        }
                    }
                }

                # Create symlink for pwsh profile
                if (-not (Test-Path $pwshProfilePath)) {
                    try {
                        $devModeKey = Get-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\AppModelUnlock" -Name "AllowDevelopmentWithoutDevLicense" -ErrorAction SilentlyContinue
                        if ($devModeKey -and $devModeKey.AllowDevelopmentWithoutDevLicense -eq 1) {
                            cmd.exe /c "mklink `"$pwshProfilePath`" `"$sourceProfile`" >nul 2>&1"
                        } else {
                            gsudo cmd.exe /c "mklink `"$pwshProfilePath`" `"$sourceProfile`" >nul 2>&1"
                        }
                    } catch {
                        gsudo cmd.exe /c "mklink `"$pwshProfilePath`" `"$sourceProfile`" >nul 2>&1"
                    }
                    Write-Host "Created pwsh profile link: $pwshProfilePath -> $sourceProfile" -ForegroundColor Green
                }
            }
        }
    }

    # Cleanup and finalize
    gsudo config CacheMode Explicit
    gsudo config LogLevel "Info" | Out-Null

    [SetupHelper]::WriteInfo("Setup completed successfully!")
    Write-Host "Tip: Run 'cheat' in PowerShell to view the terminal tools cheatsheet." -ForegroundColor Cyan
}
catch {
    Write-Host "Setup failed: $_" -ForegroundColor Red
}
finally {
    Stop-Transcript
}

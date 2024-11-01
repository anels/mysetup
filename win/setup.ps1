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

        if (Test-Path $Target) {
            gsudo Remove-Item $Target -Force
        }

        $targetDir = Split-Path -Parent $Target
        if (!(Test-Path $targetDir)) {
            New-Item -Path $targetDir -ItemType Directory -Force | Out-Null
        }

        gsudo New-Item -Path $Target -ItemType SymbolicLink -Value $Source -Force | Out-Null
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
        irm get.scoop.sh | iex
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
    gsudo cache on -d -1

    # Install applications and configure system
    . $PSScriptRoot\apps\scoop.ps1
    . $PSScriptRoot\apps\pip.ps1

    # Setup VS Code if installed
    if ([SetupHelper]::TestCommand('code')) {
        [SetupHelper]::WriteInfo("Setting up VS Code...")
        . $PSScriptRoot\vscode\vscode.ps1
        New-SoftLink -Source $PSScriptRoot\vscode\settings.json -Target $Home\scoop\apps\vscode\current\data\user-data\User\settings.json
    }

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
            if (($null -eq $existing) -or (-not $existing.Contains($value))) {
                git config --global --add $config.Key $value
            }
        }
    }

    # Cleanup and finalize
    gsudo cache off
    gsudo config LogLevel "Info" | Out-Null
    
    [SetupHelper]::WriteInfo("Setup completed successfully!")
}
catch {
    Write-Host "Setup failed: $_" -ForegroundColor Red
}
finally {
    Stop-Transcript
}

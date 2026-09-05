# PowerShell Profile Configuration
# Create a parameter to control verbose logging - set to $false by default
param([switch]$Verbose = $false)

if ($global:myProfileLoaded) { return }
$global:myProfileLoaded = $true

$profileLoadStart = Get-Date

#----------------------------------------------------------------------
# Section: Initial Configuration
#----------------------------------------------------------------------

# Configure verbose logging
if ($Verbose -or ($env:PS_PROFILE_VERBOSE -eq "true")) {
    $VerbosePreference = "Continue"
    Write-Host "Verbose logging enabled. Set `$env:PS_PROFILE_VERBOSE = `$false to disable." -ForegroundColor Yellow
}
else {
    $VerbosePreference = "SilentlyContinue"
}

#----------------------------------------------------------------------
# Section: Core Functions
#----------------------------------------------------------------------

# Profile reload function - defined here for reliability
function Restart-PowerShell {
    if ($host.Name -eq 'ConsoleHost') {
        clear
        $global:myProfileLoaded = $false
        .$profile
    }
    else {
        Write-Warning 'Only usable while in the PowerShell console host'
    }
}
Set-Alias -Name 'reload' -Value 'Restart-PowerShell'

# Simple module import helper - optimized to avoid slow Get-Module -ListAvailable
function Enable-Module ($moduleName) {
    Import-Module -Name $moduleName -ErrorAction SilentlyContinue
}

# Import selected modules with proper error handling
function Import-SelectedModules {
    [CmdletBinding()]
    param()

    # Skip if modules path doesn't exist
    if (-not (Test-Path $modulesPath)) {
        Write-Warning "Modules path not found: $modulesPath"
        return
    }

    # Import each selected module
    foreach ($moduleName in $importModules.Keys) {
        if ($importModules[$moduleName]) {
            $modulePath = Join-Path -Path $modulesPath -ChildPath "$moduleName.psm1"

            if (Test-Path $modulePath) {
                Write-Verbose "Importing module: $modulePath"
                try {
                    Import-Module -Name $modulePath -Force -Global -ErrorAction Stop
                    Write-Verbose "Successfully imported module: $moduleName"
                }
                catch {
                    Write-Warning "Failed to import $moduleName module: $_"
                }
            }
            else {
                Write-Warning "Module file not found: $modulePath"
            }
        }
        else {
            Write-Verbose "Skipping module: $moduleName (disabled in profile.local.ps1)"
        }
    }
}

#----------------------------------------------------------------------
# Section: Theme Configuration
#----------------------------------------------------------------------

# Set POSH_THEMES_PATH for Scoop installation
if (-not $env:POSH_THEMES_PATH) {
    $env:POSH_THEMES_PATH = "$env:USERPROFILE\scoop\apps\oh-my-posh\current\themes"
}

# Oh-my-posh theme configuration
function Set-OhMyPoshThemes {
    param ([string]$name)

    $omhJsonFilePath = "$env:POSH_THEMES_PATH\$name.omp.json"
    if (($null -ne (Get-Command oh-my-posh -ErrorAction:SilentlyContinue)) -And (Test-Path -Path $omhJsonFilePath -PathType Leaf)) {
        # Temporarily set ErrorActionPreference to suppress errors about missing functions
        $oldErrorAction = $ErrorActionPreference
        $ErrorActionPreference = 'SilentlyContinue'

        try {
            # Remove the function if it exists to avoid errors
            Get-ChildItem -Path Function: -Name Get-PoshStackCount -ErrorAction SilentlyContinue |
            ForEach-Object { Remove-Item -Path "Function:\$_" -Force }

            # Use correct shell type for PowerShell 5 vs 7+
            $shellType = if ($PSVersionTable.PSVersion.Major -eq 5) { "powershell" } else { "pwsh" }
            oh-my-posh init $shellType --config $omhJsonFilePath | Invoke-Expression
        }
        catch {
            Write-Warning "Error initializing oh-my-posh: $_"
        }
        finally {
            # Restore the original error action preference
            $ErrorActionPreference = $oldErrorAction
        }
        return $true
    }
    return $false
}

# Theme collections
$myTheme = @(
    "avit", "peru", "wopian",
    "amro", "catppuccin_mocha", "catppuccin", "cobalt2", "dracula",
    "emodipt", "gruvbox", "half-life",
    "hotstick.minimal", "huvix", "json", "lambda", "larserikfinholt",
    "marcduiker", "material", "montys", "multiverse-neon",
    "pararussel", "powerline", "probua.minimal",
    "pure", "robbyrussell", "sorin", "space", "spaceship", "star",
    "stelbent-compact.minimal", "the-unnamed", "tokyonight_storm",
    "tonybaloney", "wholespace", "ys", "zash"
)

$myThemeForPS5 = @(
    "darkblood", "half-life", "kali", "material", "onehalf.minimal",
    "probua.minimal", "pure", "xtoy", "ys"
)

# System info display function
function Show-SystemInfo {
    if ((Get-Random -Minimum 0 -Maximum 1.0) -lt 0.1 -And
        $Host.UI.RawUI.WindowSize.Width -ge 120 -And
        $Host.UI.RawUI.WindowSize.Height -ge 32) {
        fastfetch
    }
}

#----------------------------------------------------------------------
# Section: Alias Management
#----------------------------------------------------------------------

# A module counts as disabled when profile.local.ps1 sets it to $false or leaves it
# out of $importModules entirely; missing functions from those are expected, not warnings.
function Test-ModuleEnabled {
    param ([string]$ModuleName)

    $importModulesVar = Get-Variable -Name importModules -ValueOnly -ErrorAction SilentlyContinue
    if (-not $importModulesVar) { return $true }
    return [bool]$importModulesVar[$ModuleName]
}

# Function to set aliases with proper fallbacks and warnings
function Set-FunctionAlias {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory = $true)][string]$Alias,
        [Parameter(Mandatory = $true)][string]$Function,
        [Parameter(Mandatory = $false)][string]$FallbackFunction,
        [Parameter(Mandatory = $true)][string]$ModuleName,
        [Parameter(Mandatory = $false)][string]$Description = ""
    )

    # Try to create the alias with the primary function
    # Note: Check if function exists - this means module was loaded
    if (Get-Command -Name $Function -ErrorAction SilentlyContinue) {
        Set-Alias -Name $Alias -Value $Function -Scope Global -Force -ErrorAction SilentlyContinue
        Write-Verbose "Created alias '$Alias' for function '$Function'"
        return $true
    }

    # Try to use the fallback function if provided
    if ($FallbackFunction -and (Get-Command -Name $FallbackFunction -ErrorAction SilentlyContinue)) {
        Set-Alias -Name $Alias -Value $FallbackFunction -Scope Global -Force -ErrorAction SilentlyContinue
        Write-Verbose "Created alias '$Alias' for fallback function '$FallbackFunction'"
        return $true
    }

    # Both the function and its fallback are missing: warn only if the module was
    # supposed to be loaded at all.
    if (Test-ModuleEnabled -ModuleName $ModuleName) {
        $msg = if ($FallbackFunction) {
            "$Function (formerly $FallbackFunction) not found. The $Alias alias may not work."
        } else {
            "$Function not found. The $Alias alias may not work."
        }
        if ($Description) { $msg += " $Description" }
        Write-Warning $msg
    }
    else {
        Write-Verbose "Skipping warning for '$Function' - module '$ModuleName' is disabled"
    }

    return $false
}

#----------------------------------------------------------------------
# Section: Profile Initialization
#----------------------------------------------------------------------

# Load profile.local.ps1 if it exists - cache result to avoid duplicate checks
$script:hasLocalProfile = Test-Path "~\profile.local.ps1"
if ($script:hasLocalProfile) {
    Write-Verbose "Loading profile.local.ps1..."
    try {
        . ~\profile.local.ps1
        Write-Verbose "Local profile loaded successfully."
    }
    catch {
        Write-Warning "Error loading profile.local.ps1: $_"
    }
}
else {
    Write-Warning "profile.local.ps1 not found. Module imports may be unavailable."
    Write-Warning "Create this file in your home directory to customize module imports."

    # Fallback modules path if no local profile
    if (-not (Test-Path Variable:\modulesPath)) {
        # Dynamically determine path based on script location
        $scriptPath = Split-Path -Parent $MyInvocation.MyCommand.Definition
        $modulesPath = Join-Path $scriptPath "modules"
        Write-Verbose "Using fallback modules path: $modulesPath"
    }
}

Write-Verbose "Custom modules path: $modulesPath"

#----------------------------------------------------------------------
# Section: Load Essential Modules & Tools
#----------------------------------------------------------------------

# Setup gsudo
$GsudoModuleFilePath = "$Home\scoop\apps\gsudo\current\gsudoModule.psd1"
if (Test-Path $GsudoModuleFilePath -PathType Leaf) {
    Import-Module $GsudoModuleFilePath
    Set-Alias -Name 'sudo' -Value 'gsudo'
}

# Load PSReadLine - optimized to avoid slow Get-Module -ListAvailable
if ($host.Name -eq 'ConsoleHost') {
    try {
        Import-Module PSReadLine -ErrorAction Stop
        Set-PSReadLineOption -PredictionSource History -EditMode Windows

        $windowSize = (Get-Host).UI.RawUI.MaxWindowSize
        if ($windowSize.Width -ge 54 -and $windowSize.Height -ge 20) {
            Set-PSReadLineOption -PredictionViewStyle ListView
        }
    }
    catch {
        # PSReadLine not available
    }
}

# Common module imports
Enable-Module Terminal-Icons
Enable-Module posh-git
Enable-Module posh-docker
Enable-Module scoop-completion

# Set kubectl alias if available - simplified check
if (Get-Command kubectl -ErrorAction SilentlyContinue) {
    Set-Alias -Name 'k' -Value 'kubectl'
}

#----------------------------------------------------------------------
# Section: Theme Configuration Application
#----------------------------------------------------------------------

# Select and apply a theme
$theme = if ($PSVersionTable.PSVersion.Major -eq 5) {
    Get-Random -InputObject $myThemeForPS5
}
else {
    Get-Random -InputObject $myTheme
}

Write-Host "Theme: $theme"
if (-Not (Set-OhMyPoshThemes $theme) -and (Get-Command "starship" -ErrorAction SilentlyContinue)) {
    Invoke-Expression (&starship init powershell)
}

#----------------------------------------------------------------------
# Section: Custom Aliases Setup
#----------------------------------------------------------------------

# Import selected modules if profile.local.ps1 was loaded - use cached result
if ($script:hasLocalProfile) {
    Write-Verbose "Local profile was loaded. Setting up aliases for imported modules..."
    # Import the modules
    Import-SelectedModules
}

# Set up aliases only for enabled modules
# Define all alias configurations in a centralized array
$aliasConfigs = @(
    # Git-related aliases
    @{ Alias = "cugb"; Function = "Clear-GitBranch"; Fallback = "Cleanup-GitBranch"; Module = "GitTools" },
    @{ Alias = "ccppr"; Function = "New-CherryPickPR"; Fallback = "Create-CherryPickPR"; Module = "GitTools" },

    # Utility function aliases
    @{ Alias = "time"; Function = "Measure-Command2"; Fallback = ""; Module = "UtilityTools" },
    @{ Alias = "upall"; Function = "Update-All"; Fallback = ""; Module = "UtilityTools" },
    @{ Alias = "ohis"; Function = "Open-PSHistory"; Fallback = ""; Module = "UtilityTools" },
    @{ Alias = "ohos"; Function = "Open-Hosts"; Fallback = ""; Module = "UtilityTools" },
    @{ Alias = "printenv"; Function = "Get-EnvironmentVariables"; Fallback = ""; Module = "UtilityTools" },
    @{ Alias = "chst"; Function = "Test-WebsiteStatus"; Fallback = "CheckStatus"; Module = "UtilityTools" },
    @{ Alias = "wimi"; Function = "Get-MyPublicIP"; Fallback = ""; Module = "UtilityTools" },
    @{ Alias = "isadmin"; Function = "Test-Admin"; Fallback = ""; Module = "UtilityTools" },
    @{ Alias = "gsd"; Function = "Get-ScriptDirectory"; Fallback = ""; Module = "UtilityTools" },
    @{ Alias = "spath"; Function = "Show-Path"; Fallback = ""; Module = "UtilityTools" },

    # Looker-related aliases
    @{ Alias = "dlook"; Function = "Invoke-LookerDownload"; Fallback = ""; Module = "LookerTools" },
    @{ Alias = "savelook"; Function = "Save-LookerJar"; Fallback = "Download-LookerJar"; Module = "LookerTools" }
)

# Batch process alias configurations, but only for enabled modules
foreach ($config in $aliasConfigs) {
    if (-not (Test-ModuleEnabled -ModuleName $config.Module)) {
        Write-Verbose "Skipping alias '$($config.Alias)' - module '$($config.Module)' is disabled"
        continue
    }

    $params = @{
        Alias      = $config.Alias
        Function   = $config.Function
        ModuleName = $config.Module
    }
    if ($config.Fallback) {
        $params.FallbackFunction = $config.Fallback
    }
    $null = Set-FunctionAlias @params
}

#----------------------------------------------------------------------
# Section: Terminal Tools
#----------------------------------------------------------------------

# Cheatsheet quick-view alias (derives path from profile location)
if (Get-Command glow -ErrorAction SilentlyContinue) {
    $script:cheatsheetPath = Join-Path $PSScriptRoot "terminal-tools-cheatsheet.md"
    function Show-TerminalCheatsheet { glow -p $script:cheatsheetPath }
    Set-Alias -Name 'cheat' -Value 'Show-TerminalCheatsheet'
}

# Modern CLI tool aliases
if (Get-Command eza -ErrorAction SilentlyContinue) {
    function Invoke-Eza { eza -la --icons --git --group-directories-first @args }
    function Invoke-EzaTree { eza --tree --level=2 --icons @args }
    Set-Alias -Name 'ls' -Value 'Invoke-Eza' -Force -Option AllScope
    Set-Alias -Name 'lt' -Value 'Invoke-EzaTree'
}

if (Get-Command bat -ErrorAction SilentlyContinue) {
    Set-Alias -Name 'cat' -Value 'bat' -Force -Option AllScope
}

if (Get-Command zoxide -ErrorAction SilentlyContinue) {
    Invoke-Expression (&zoxide init powershell | Out-String)
}

#----------------------------------------------------------------------
# Section: Finalization
#----------------------------------------------------------------------

# Reset verbose preference if it was temporarily enabled
if ($Verbose -or ($env:PS_PROFILE_VERBOSE -eq "true")) {
    $VerbosePreference = "SilentlyContinue"
    Write-Host "Verbose logging disabled."
}

# Display load time
Write-Host "Profile loaded in $((Get-Date) - $profileLoadStart)"

# Optionally show system info (uncomment to enable)
# Show-SystemInfo

#f45873b3-b655-43a6-b217-97c00aa0db58 PowerToys CommandNotFound module
# Deferred to background to avoid 300-800ms startup delay
if (Get-Command Start-ThreadJob -ErrorAction SilentlyContinue) {
    $null = Start-ThreadJob -ScriptBlock { Import-Module Microsoft.WinGet.CommandNotFound } -ErrorAction SilentlyContinue
}
else {
    # Fallback: load synchronously if ThreadJob not available (uncomment if needed)
    # Import-Module -Name Microsoft.WinGet.CommandNotFound
}
#f45873b3-b655-43a6-b217-97c00aa0db58


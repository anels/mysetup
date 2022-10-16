# Local PowerShell profile for machine-specific settings
# This file is loaded by the main profile and contains environment-specific settings

# Set the modules path for this specific machine
$modulesPath = "[DOTFILES_MODULES_PATH]"

# Define environment-specific settings
# These values may contain sensitive information and should not be shared
# Uncomment and set your Looker license key to avoid being prompted each time
# $global:LOOKER_LICENSE_KEY = "your-license-key"  # Your Looker license key
# $global:LOOKER_LICENSE_EMAIL = "your-email@example.com"  # Your Looker license email

# Define which modules to import on this machine
# Set to $true to import, $false to skip
$importModules = @{
    "GitTools"     = $true  # Git-related functions (Create-CherryPickPR, Clear-GitBranch)
    "UtilityTools" = $true  # Utility functions (Measure-Command2, Update-All, etc.)
    "LookerTools"  = $true  # Looker-related functions (Save-LookerJar, Invoke-LookerDownload)
    # Add other modules here as needed
}

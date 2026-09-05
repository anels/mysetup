# LookerTools Module - Contains functions for working with Looker

# Renamed from Download-LookerJar to Save-LookerJar to use an approved PowerShell verb
function Save-LookerJar {
    param (
        [Parameter(Mandatory = $true)][string]$LOOKER_VERSION,
        [Parameter(Mandatory = $true)][string]$LOOKER_LICENSE,
        [Parameter(Mandatory = $true)][string]$LOOKER_EMAIL
    )

    $info = $(Invoke-RestMethod -Method POST -ContentType "application/json" -uri "https://apidownload.looker.com/download" -Body "{`"lic`": `"$LOOKER_LICENSE`", `"email`": `"$LOOKER_EMAIL`",`"latest`":`"specific`", `"specific`":`"looker-$LOOKER_VERSION-latest.jar`"}")
    if ($null -eq $info.version_text) {
        Write-Error "No such version $LOOKER_VERSION."
        return
    }

    $LATEST_VERSION = ($info.version_text -replace '\.jar', '')
    if (Test-Path $LATEST_VERSION) {
        Write-Output "The version $LATEST_VERSION is already downloaded."
        return
    }

    $null = New-Item -Path $LATEST_VERSION -ItemType Directory -Force
    Write-Output "Downloading looker.jar file to `"$LATEST_VERSION`""
    Invoke-WebRequest $info.url -OutFile $LATEST_VERSION/looker.jar
    Write-Output "Downloading looker-dependencies.jar file to `"$LATEST_VERSION`""
    Invoke-WebRequest $info.depUrl -OutFile $LATEST_VERSION/looker-dependencies.jar
}

# Keep Download-LookerJar as an alias for backward compatibility
New-Alias -Name Download-LookerJar -Value Save-LookerJar

# Prompt for a value with retries. Returns $null when the user cancels or runs out of attempts.
function Read-LookerValue {
    param (
        [Parameter(Mandatory = $true)][string]$Prompt,
        [string]$Pattern,
        [int]$MaxAttempts = 3
    )

    for ($attempt = 1; $attempt -le $MaxAttempts; $attempt++) {
        if ($attempt -gt 1) { Write-Host "Attempt $attempt of $MaxAttempts" -ForegroundColor Yellow }
        $value = Read-Host "$Prompt (or type 'cancel' to abort)"
        if ($value -eq 'cancel') {
            Write-Host "Operation cancelled by user." -ForegroundColor Cyan
            return $null
        }
        if (-not [string]::IsNullOrWhiteSpace($value) -and ([string]::IsNullOrEmpty($Pattern) -or $value -match $Pattern)) {
            return $value
        }
        Write-Error "Invalid input. Please try again."
    }

    Write-Error "Failed to provide a valid value after $MaxAttempts attempts. Operation aborted."
    return $null
}

function Invoke-LookerDownload {
    param (
        [Parameter(Mandatory = $false)][string]$LOOKER_VERSION = "25.6",
        [Parameter(Mandatory = $false)][string]$LOOKER_LICENSE = $null,
        [Parameter(Mandatory = $false)][string]$LOOKER_EMAIL = $null
    )

    # Check if we need to prompt for license or email
    $needToPromptLicense = $false
    $needToPromptEmail = $false

    # Handle License Key
    if ($null -eq $LOOKER_LICENSE -or $LOOKER_LICENSE -eq '') {
        if (Get-Variable -Name LOOKER_LICENSE_KEY -Scope Global -ErrorAction SilentlyContinue) {
            $LOOKER_LICENSE = $global:LOOKER_LICENSE_KEY
            if ([string]::IsNullOrWhiteSpace($LOOKER_LICENSE)) {
                Write-Host "The LOOKER_LICENSE_KEY in your profile is empty." -ForegroundColor Yellow
                $needToPromptLicense = $true
            }
        }
        else {
            $needToPromptLicense = $true
        }
    }

    # Handle License Email
    if ($null -eq $LOOKER_EMAIL -or $LOOKER_EMAIL -eq '') {
        if (Get-Variable -Name LOOKER_LICENSE_EMAIL -Scope Global -ErrorAction SilentlyContinue) {
            $LOOKER_EMAIL = $global:LOOKER_LICENSE_EMAIL
            if ([string]::IsNullOrWhiteSpace($LOOKER_EMAIL)) {
                Write-Host "The LOOKER_LICENSE_EMAIL in your profile is empty." -ForegroundColor Yellow
                $needToPromptEmail = $true
            }
        }
        else {
            $needToPromptEmail = $true
        }
    }

    # Prompt for the values that are still missing
    if ($needToPromptLicense) {
        Write-Host "Looker license key required but not found." -ForegroundColor Yellow
        Write-Host "You can add it to your profile.local.ps1 file to avoid this prompt in the future:" -ForegroundColor Yellow
        Write-Host "`$global:LOOKER_LICENSE_KEY = 'your-license-key'" -ForegroundColor Gray

        $LOOKER_LICENSE = Read-LookerValue -Prompt "Please enter your Looker license key"
        if (-not $LOOKER_LICENSE) { return }
    }

    if ($needToPromptEmail) {
        Write-Host "Looker license email required but not found." -ForegroundColor Yellow
        Write-Host "You can add it to your profile.local.ps1 file to avoid this prompt in the future:" -ForegroundColor Yellow
        Write-Host "`$global:LOOKER_LICENSE_EMAIL = 'your-email@domain.com'" -ForegroundColor Gray

        $LOOKER_EMAIL = Read-LookerValue -Prompt "Please enter your Looker license email" -Pattern '^[^@]+@[^@]+\.[^@]+$'
        if (-not $LOOKER_EMAIL) { return }
    }

    # Final validation
    if ([string]::IsNullOrWhiteSpace($LOOKER_LICENSE) -or [string]::IsNullOrWhiteSpace($LOOKER_EMAIL)) {
        Write-Error "License key or email missing. Cannot download Looker JAR."
        return
    }

    # Download the JAR
    $originalLocation = Get-Location
    try {
        # Ensure the LookerJar directory exists
        if (-not (Test-Path ~/LookerJar)) {
            Write-Host "Creating LookerJar directory..." -ForegroundColor Yellow
            New-Item -Path ~/LookerJar -ItemType Directory -Force | Out-Null
        }

        Set-Location ~/LookerJar
        Write-Host "Downloading Looker version $LOOKER_VERSION..." -ForegroundColor Cyan
        Save-LookerJar -LOOKER_VERSION $LOOKER_VERSION -LOOKER_LICENSE $LOOKER_LICENSE -LOOKER_EMAIL $LOOKER_EMAIL
    }
    finally {
        Set-Location $originalLocation
    }
}

# Make sure to explicitly export the functions so they're available when imported
Export-ModuleMember -Function Save-LookerJar, Invoke-LookerDownload -Alias Download-LookerJar

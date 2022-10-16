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

    mkdir -p $LATEST_VERSION
    Write-Output "Downloading looker.jar file to `"$LATEST_VERSION`""
    Invoke-WebRequest $info.url -OutFile $LATEST_VERSION/looker.jar
    Write-Output "Downloading looker-dependencies.jar file to `"$LATEST_VERSION`""
    Invoke-WebRequest $info.depUrl -OutFile $LATEST_VERSION/looker-dependencies.jar
}

# Keep Download-LookerJar as an alias for backward compatibility
New-Alias -Name Download-LookerJar -Value Save-LookerJar

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

    # Prompt for License Key if needed
    if ($needToPromptLicense) {
        Write-Host "Looker license key required but not found." -ForegroundColor Yellow
        Write-Host "You can add it to your profile.local.ps1 file to avoid this prompt in the future:" -ForegroundColor Yellow
        Write-Host "`$global:LOOKER_LICENSE_KEY = 'your-license-key'" -ForegroundColor Gray

        $maxAttempts = 3
        $attempt = 0
        $validKey = $false

        while (-not $validKey -and $attempt -lt $maxAttempts) {
            $attempt++
            if ($attempt > 1) { Write-Host "Attempt $attempt of $maxAttempts" -ForegroundColor Yellow }
            $LOOKER_LICENSE = Read-Host "Please enter your Looker license key (or type 'cancel' to abort)"
            if ($LOOKER_LICENSE -eq 'cancel') { Write-Host "Operation cancelled by user." -ForegroundColor Cyan; return }
            if ([string]::IsNullOrWhiteSpace($LOOKER_LICENSE)) { Write-Error "License key cannot be empty. Please try again." }
            else { $validKey = $true }
        }

        if (-not $validKey) {
            Write-Error "Failed to provide a valid license key after $maxAttempts attempts. Operation aborted."
            return
        }
    }

    # Prompt for Email if needed
    if ($needToPromptEmail) {
        Write-Host "Looker license email required but not found." -ForegroundColor Yellow
        Write-Host "You can add it to your profile.local.ps1 file to avoid this prompt in the future:" -ForegroundColor Yellow
        Write-Host "`$global:LOOKER_LICENSE_EMAIL = 'your-email@domain.com'" -ForegroundColor Gray

        $maxAttempts = 3
        $attempt = 0
        $validEmail = $false

        while (-not $validEmail -and $attempt -lt $maxAttempts) {
            $attempt++
            if ($attempt > 1) { Write-Host "Attempt $attempt of $maxAttempts" -ForegroundColor Yellow }
            $LOOKER_EMAIL = Read-Host "Please enter your Looker license email (or type 'cancel' to abort)"
            if ($LOOKER_EMAIL -eq 'cancel') { Write-Host "Operation cancelled by user." -ForegroundColor Cyan; return }
            if ([string]::IsNullOrWhiteSpace($LOOKER_EMAIL) -or $LOOKER_EMAIL -notlike "*@*.*") { Write-Error "Please enter a valid email address. Please try again." }
            else { $validEmail = $true }
        }

        if (-not $validEmail) {
            Write-Error "Failed to provide a valid email address after $maxAttempts attempts. Operation aborted."
            return
        }
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

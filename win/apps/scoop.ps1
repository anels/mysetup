Write-Host ""
Write-Host "Installing Applications from Scoop..." -ForegroundColor Green
Write-Host "------------------------------------" -ForegroundColor Green

$EnabledBuckets = $(scoop bucket list).Name
$Buckets = @(
  "extras"
  "nerd-fonts"
  "versions"
  "java"
)

foreach ($bucket in $Buckets) {
  if ($bucket -notin $EnabledBuckets) {
    scoop bucket add $bucket
  }
}

# scoop update *
# scoop cleanup *

$InstalledApps = $(scoop list 6>$null).Name

$CommonApps = $(
  "7zip"
  "bitwarden"
  "bottom"
  "broot"
  "bulk-crap-uninstaller"
  "coreutils"
  "crystaldiskinfo"
  "delta"
  "dismplusplus"
  "ditto"
  "duf"
  "dust"
  "eartrumpet"
  "everything"
  "imageglass"
  "jq"
  "macast"
  "marktext"
  "meld"
  "musicbee"
  "nexusfont"
  "notepadplusplus"
  "oh-my-posh" # A prompt theme engine for any shell
  "openjdk"
  "posh-git" # A PowerShell environment for Git
  "potplayer"
  "psreadline"
  "pwsh"
  "scoop-completion"
  "snipaste"
  "sysinternals"
  "terminal-icons" # A PowerShell module to show file and folder icons in the terminal
  "tldr"
  "treesize-free"
  "twinkle-tray"
  "universal-ctags"
  "vim"
  "vscode"
  "windirstat"
  "windows-terminal"
  "winfetch"
  "z" # A new cd command that helps you navigate faster by learning your habits
  # fzf - A command-line fuzzy finder
  # googlechrome
  # less
  # psfzf - A PowerShell wrapper around the fzf
  # winmerge
)

$VersionedApps = $(
  "python39"
)

$Fonts = $(
  # "CascadiaCode-NF"
  # "FiraMono-NF"
  # "Hack-NF"
  # "JetBrainsMono-NF"
  # "SourceCodePro-NF"
  # "VictorMono-NF"
  "AnonymousPro-NF-Mono"
  "CascadiaCode-NF-Mono"
  "FiraCode-NF-Mono"
  "Hack-NF-Mono"
  "JetBrainsMono-NF-Mono"
  "RobotoMono-NF-Mono"
  "SourceCodePro-NF-Mono"
)

foreach ($app in $CommonApps) {
  if ($app -in $InstalledApps) {
    Write-Host "${app} is already installed."
  }
  else {
    scoop install $app
  }
}

# versions
foreach ($app in $VersionedApps) {
  if ($app -in $InstalledApps) {
    Write-Host "${app} is already installed."
  }
  else {
    scoop install $app
  }
}

# nerd-fonts
# Currently, on Windows 11 Version 22H2 (OS Build 22621) or later,
# Font installation only works when installing font for all users.
foreach ($font in $Fonts) {
  if ($font -in $InstalledApps) {
    Write-Host "${font} is already installed."
  }
  else {
    scoop install -g $font
  }
}

# additional dev tools
# scoop install
#   helm
#   openlens
#   mremoteng
#   dbeaver
#   github
#   zoom
#   nodejs
#   azure-cli
#   posh-docker # Import-Module posh-docker

$RegItems = @(
  "$Home\scoop\apps\eartrumpet\current\add-startup.reg"
  "$Home\scoop\apps\notepadplusplus\current\install-context.reg"
  "$Home\scoop\apps\python39\current\install-pep-514.reg"
  "$Home\scoop\apps\vscode\current\install-associations.reg"
  "$Home\scoop\apps\windows-terminal\current\install-context.reg"
)

Write-Host "Importing Reg Items..."
foreach ($item in $RegItems) {
  if (Test-Path $item -PathType Leaf) {
    # Write-Host "Importing ${item}..."
    reg import $item
  }
}

# # InstalledModule -Name psreadline -AllVersions
# Install-Module PSReadLine -Force -AllowPrerelease -SkipPublisherCheck
# Import PackageManager module
Import-Module "$PSScriptRoot\..\dotfiles\modules\PackageManager.psm1" -Force

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

$GlobalApps = $(
  "vcredist2022"
)

# --- CLI Tools (modern replacements & terminal productivity) ---
$CliTools = $(
  "bat"           # cat replacement with syntax highlighting
  "bottom"        # top/htop replacement (btm)
  "broot"         # tree navigation + fuzzy search
  "btop"          # resource monitor
  "coreutils"
  "delta"         # git diff viewer
  "duf"           # df replacement
  "dust"          # du replacement
  "eza"           # ls replacement with git integration
  "fastfetch"     # system info
  "fd"            # find replacement
  "ffmpeg"        # video thumbnails
  "fx"            # interactive JSON viewer
  "fzf"           # fuzzy finder
  "gh"              # GitHub CLI
  "glow"          # markdown renderer
  "imagemagick"   # font, HEIC, JPEG XL preview
  "jid"           # JSON interactive digger
  "jq"            # JSON processor
  "lazygit"       # git TUI
  "less"
  "lsd"           # ls with icons
  "nano"
  "neovim"        # Modern vim
  "poppler"       # PDF preview
  "procs"         # ps replacement
  "resvg"         # SVG preview
  "ripgrep"       # grep replacement (rg)
  "scoop-search"  # faster scoop search
  "sd"            # sed replacement
  "starship"      # cross-shell prompt
  "tldr"          # man replacement
  "universal-ctags"
  "vim"
  "xh"            # curl/httpie replacement
  "yazi"          # terminal file manager
  "yt-dlp"        # Video downloader
  "zoxide"        # cd replacement
  # yazi preview dependencies
)

# --- Shell & PowerShell ---
$ShellTools = $(
  "oh-my-posh"        # prompt theme engine
  "openssh"
  "posh-git"          # PowerShell Git integration
  "psreadline"
  "pwsh"              # PowerShell 7
  "scoop-completion"
  "terminal-icons"    # file/folder icons in terminal
  "windows-terminal"
)

# --- Desktop Apps ---
$DesktopApps = $(
  "7zip"
  "bitwarden"
  "bulk-crap-uninstaller"
  "cherry-studio"     # AI Studio
  "crystaldiskinfo"
  "dismplusplus"
  "ditto"             # clipboard manager
  "everything"        # instant file search
  "gitahead"
  "imageglass"
  "joplin"
  "macast"
  "marktext"
  "musicbee"
  "nexusfont"
  "obsidian"
  "picard"            # music tagger
  "quicklook"
  "screentogif"
  "snipaste"
  "spacesniffer"
  "sumatrapdf"
  "sysinternals"
  "treesize-free"
  "vscode"
  "wechat"
  "windirstat"
  # "eartrumpet"
  # "extras/balabolka"
  # "extras/easy-context-menu"
  # "extras/nilesoft-shell"
  # "googlechrome"
  # "onefetch"
  # "potplayer"
  # "powertoys"
  # "trafficmonitor"   # taskbar network/CPU monitor
  # "translucenttb"    # transparent taskbar
  # "twinkle-tray"
  # "winmerge"
  # "zed"              # Rust editor
)

# --- Dev Runtimes ---
$DevRuntimes = $(
  "bun"             # JS runtime
  "nvm"             # Node version manager
  "openjdk"
  "pnpm"            # Node package manager
  "python312"
  "uv"              # fast Python package manager
)

# --- Dev Tools (optional, prompted during setup) --
$DevTools = $(
  "aws-iam-authenticator" # AWS K8s auth
  "azure-kubelogin" # Azure K8s auth
  "azurestorageexplorer" # Azure Storage browser
  "dbeaver"         # database GUI
  "dive"            # Docker image layer analysis
  "fork"            # Git GUI
  "github"          # GitHub Desktop
  "helm"            # Kubernetes package manager
  "hoppscotch"      # API testing
  "k9s"             # Kubernetes TUI
  "kubectl"         # Kubernetes CLI
  "mremoteng"       # remote connection manager
  "openssl"         # crypto toolkit
  "redis-tui"       # Redis TUI client
  "sbt"             # Scala build tool
  "sqlite"          # embedded database
  "terraform"       # Infrastructure as Code
  "tilt"            # K8s dev workflow
  "winscp"          # SFTP/FTP client
)

$Fonts = $(
  "AnonymousPro-NF-Mono"
  "CascadiaCode-NF-Mono"
  "FiraCode-NF-Mono"
  "Hack-NF-Mono"
  "UbuntuMono-NF-Mono"
  "Iosevka-NF-Mono"
  "IosevkaTerm-NF-Mono"
  "JetBrainsMono-NF-Mono"
  "SourceCodePro-NF-Mono"
  "Maple-Mono-NF"
  # "CascadiaCode-NF"
  # "FiraMono-NF"
  # "Hack-NF"
  # "JetBrainsMono-NF"
  # "SourceCodePro-NF"
  # "VictorMono-NF"
)

Install-Packages -PackageManager 'scoop' -Packages $GlobalApps -GlobalInstall -Label "Global Dependencies"

# nerd-fonts
# Currently, on Windows 11 Version 22H2 (OS Build 22621) or later,
# Font installation only works when installing font for all users.
Install-Packages -PackageManager 'scoop' -Packages $Fonts -GlobalInstall -Label "Nerd Fonts"

Install-Packages -PackageManager 'scoop' -Packages $CliTools -Label "CLI Tools"
Install-Packages -PackageManager 'scoop' -Packages $ShellTools -Label "Shell & PowerShell"
Install-Packages -PackageManager 'scoop' -Packages $DesktopApps -Label "Desktop Apps"
Install-Packages -PackageManager 'scoop' -Packages $DevRuntimes -Label "Dev Runtimes"

# Dev Tools — optional, prompt user
$installDevTools = Read-Host "`nInstall Dev Tools (K8s, Terraform, DB tools, etc.)? [y/N]"
if ($installDevTools -eq 'y' -or $installDevTools -eq 'Y') {
  Install-Packages -PackageManager 'scoop' -Packages $DevTools -Label "Dev Tools"
}
else {
  Write-Host "Skipping Dev Tools." -ForegroundColor Yellow
}

# additional dev tools
# scoop install
#  helm
#  openlens
#  mremoteng
#  dbeaver
#  github
#  gh
#  zoom
#  nodejs
#  azure-cli
#  posh-docker # Import-Module posh-docker
#  main/ctop # Top-like interface for container metrics.
#  hadolint
#  hyperfine # A command-line benchmarking tool.
#  wixtoolset
#  extras/hoppscotch


# scoop bucket add dorado https://github.com/chawyehsu/dorado
# scoop install dorado/qqmusic
# scoop install dorado/qqplayer

$RegItems = @(
  #   "$Home\scoop\apps\eartrumpet\current\add-startup.reg"
  "$Home\scoop\apps\python312\current\install-pep-514.reg"
  "$Home\scoop\apps\vscode\current\install-associations.reg"
  "$Home\scoop\apps\windows-terminal\current\install-context.reg"
  "$Home\scoop\apps\7zip\current\install-context.reg"
)

Write-Host "Importing Reg Items..."
foreach ($item in $RegItems) {
  if (Test-Path $item -PathType Leaf) {
    Write-Host  -NoNewline "Importing ${item}..."
    $null = Start-Process reg.exe -ArgumentList "import `"$item`"" -Wait -NoNewWindow
    Write-Host "Done!"
  }
}

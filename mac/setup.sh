#!/usr/bin/env bash
# macOS Setup Script v1.0
# Must run as normal user (not root)
set -euo pipefail

if [[ $EUID -eq 0 ]]; then
    echo "Please run this script as a normal user, not root."
    exit 1
fi

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Setup logging
LOG_DIR="$SCRIPT_DIR/log"
mkdir -p "$LOG_DIR"
LOG_FILE="$LOG_DIR/setup_$(date +%Y%m%d%H%M%S).log"
exec > >(tee -a "$LOG_FILE") 2>&1

#----------------------------------------------------------------------
# Helper Functions
#----------------------------------------------------------------------

info() {
    echo ""
    echo -e "\033[32m$1\033[0m"
    echo "------------------------------------"
}

warn() {
    echo -e "\033[33m$1\033[0m"
}

error() {
    echo -e "\033[31m$1\033[0m"
}

command_exists() {
    command -v "$1" &>/dev/null
}

create_symlink() {
    local source="$1"
    local target="$2"

    if [[ ! -e "$source" ]]; then
        error "Source path does not exist: $source"
        return 1
    fi

    local target_dir
    target_dir="$(dirname "$target")"
    mkdir -p "$target_dir"

    if [[ -L "$target" ]]; then
        # It's a symlink, just remove it to recreate
        rm -f "$target"
    elif [[ -e "$target" ]]; then
        # It's a real file/dir, back it up
        local backup_time
        backup_time="$(date +%Y%m%d_%H%M%S)"
        local backup_path="${target}.backup_${backup_time}"
        mv "$target" "$backup_path"
        warn "Existing file found at $target. Backed up to $backup_path"
    fi

    ln -s "$source" "$target"
    echo -e "\033[32mCreated symlink: $target -> $source\033[0m"
}

#----------------------------------------------------------------------
# Main Setup
#----------------------------------------------------------------------

info "Starting macOS Setup Script v1.0"

# Install Homebrew
if ! command_exists brew; then
    info "Installing Homebrew..."
    /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"

    # Add Homebrew to PATH for Apple Silicon or Intel
    if [[ -f /opt/homebrew/bin/brew ]]; then
        eval "$(/opt/homebrew/bin/brew shellenv)"
    elif [[ -f /usr/local/bin/brew ]]; then
        eval "$(/usr/local/bin/brew shellenv)"
    fi
fi

# Disable Homebrew analytics
brew analytics off

# Install applications
info "Installing Applications from Homebrew..."
brew bundle --file="$SCRIPT_DIR/Brewfile"

source "$SCRIPT_DIR/apps/pip.sh"

# Setup VS Code if installed
if command_exists code; then
    info "Setting up VS Code..."
    source "$SCRIPT_DIR/vscode/vscode.sh"

    VSCODE_USER_DIR="$HOME/Library/Application Support/Code/User"
    create_symlink "$SCRIPT_DIR/../common/vscode/settings.json" "$VSCODE_USER_DIR/settings.json"
fi

# Git configuration
info "Setting up Git..."

add_git_config() {
    local key="$1"
    local value="$2"
    local existing
    existing="$(git config --global --get-all "$key" 2>/dev/null || true)"

    if ! echo "$existing" | grep -qF "$value"; then
        git config --global --add "$key" "$value"
    fi
}

add_git_config "include.path" "$SCRIPT_DIR/dotfiles/.gitconfig"
add_git_config "include.path" "$HOME/.gitconfig.local"
add_git_config "safe.directory" "*"

# Dotfiles setup
info "Setting up dotfiles..."

# Create .zshrc.local if it doesn't exist (machine-specific config)
LOCAL_RC="$HOME/.zshrc.local"
if [[ ! -f "$LOCAL_RC" ]]; then
    cp "$SCRIPT_DIR/dotfiles/zshrc.local.template" "$LOCAL_RC"
    echo -e "\033[32mCreated .zshrc.local at: $LOCAL_RC from template\033[0m"
else
    warn ".zshrc.local already exists at: $LOCAL_RC"
fi

# Symlink .zshrc
create_symlink "$SCRIPT_DIR/dotfiles/.zshrc" "$HOME/.zshrc"

# Symlink shell modules
MODULES_DIR="$HOME/.config/shell/modules"
mkdir -p "$MODULES_DIR"
for module_file in "$SCRIPT_DIR/dotfiles/modules/"*.sh; do
    if [[ -f "$module_file" ]]; then
        create_symlink "$module_file" "$MODULES_DIR/$(basename "$module_file")"
    fi
done

info "Setup completed successfully!"

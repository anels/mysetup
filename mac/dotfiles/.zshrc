#!/usr/bin/env zsh
# Zsh Profile Configuration for macOS

# Duplicate-load guard
[[ -n "$MY_PROFILE_LOADED" ]] && return
export MY_PROFILE_LOADED=1

zmodload zsh/datetime
PROFILE_LOAD_START=$EPOCHREALTIME

#----------------------------------------------------------------------
# Section: Initial Configuration
#----------------------------------------------------------------------

# Homebrew setup (Apple Silicon vs Intel)
if [[ -f /opt/homebrew/bin/brew ]]; then
    eval "$(/opt/homebrew/bin/brew shellenv)"
elif [[ -f /usr/local/bin/brew ]]; then
    eval "$(/usr/local/bin/brew shellenv)"
fi

# Cache brew prefix (set by brew shellenv above)
_brew_prefix="${HOMEBREW_PREFIX:-}"

#----------------------------------------------------------------------
# Section: Core Functions
#----------------------------------------------------------------------

reload() {
    unset MY_PROFILE_LOADED
    source ~/.zshrc
}

#----------------------------------------------------------------------
# Section: Load Local Configuration
#----------------------------------------------------------------------

if [[ -f ~/.zshrc.local ]]; then
    source ~/.zshrc.local
else
    echo "Warning: ~/.zshrc.local not found. Module imports may be unavailable."
    echo "Create this file in your home directory to customize module imports."
    LOAD_GIT_TOOLS="${LOAD_GIT_TOOLS:-true}"
    LOAD_UTILITY_TOOLS="${LOAD_UTILITY_TOOLS:-true}"
fi

#----------------------------------------------------------------------
# Section: Load Shell Modules
#----------------------------------------------------------------------

MODULES_DIR="$HOME/.config/shell/modules"

if [[ -d "$MODULES_DIR" ]]; then
    if [[ "${LOAD_GIT_TOOLS:-true}" == "true" && -f "$MODULES_DIR/git-tools.sh" ]]; then
        source "$MODULES_DIR/git-tools.sh"
    fi
    if [[ "${LOAD_UTILITY_TOOLS:-true}" == "true" && -f "$MODULES_DIR/utility-tools.sh" ]]; then
        source "$MODULES_DIR/utility-tools.sh"
    fi
fi

#----------------------------------------------------------------------
# Section: Zsh Options & Plugins
#----------------------------------------------------------------------

# History configuration
HISTFILE=~/.zsh_history
HISTSIZE=10000
SAVEHIST=10000
setopt HIST_IGNORE_DUPS
setopt HIST_IGNORE_SPACE
setopt SHARE_HISTORY
setopt APPEND_HISTORY

# Enable completion
autoload -Uz compinit
# Only regenerate .zcompdump once a day
if [[ -n ~/.zcompdump(#qN.mh+24) ]]; then
    compinit
else
    compinit -C
fi

# Case-insensitive completion
zstyle ':completion:*' matcher-list 'm:{a-zA-Z}={A-Za-z}'

# Load zsh plugins (installed via Homebrew)
if [[ -n "$_brew_prefix" && -f "$_brew_prefix/share/zsh-autosuggestions/zsh-autosuggestions.zsh" ]]; then
    source "$_brew_prefix/share/zsh-autosuggestions/zsh-autosuggestions.zsh"
fi
if [[ -n "$_brew_prefix" && -f "$_brew_prefix/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh" ]]; then
    source "$_brew_prefix/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh"
fi

# z - directory jumping
if command -v zoxide &>/dev/null; then
    eval "$(zoxide init zsh)"
elif [[ -n "$_brew_prefix" && -f "$_brew_prefix/etc/profile.d/z.sh" ]]; then
    source "$_brew_prefix/etc/profile.d/z.sh"
fi

#----------------------------------------------------------------------
# Section: Oh-My-Posh Theme Configuration
#----------------------------------------------------------------------

# Set POSH_THEMES_PATH for Homebrew installation
if [[ -z "$POSH_THEMES_PATH" ]]; then
    if command -v oh-my-posh &>/dev/null && [[ -n "$_brew_prefix" ]]; then
        POSH_THEMES_PATH="$_brew_prefix/opt/oh-my-posh/themes"
    fi
fi

MY_THEMES=(
    "avit" "peru" "wopian"
    "amro" "catppuccin_mocha" "catppuccin" "cobalt2" "dracula"
    "emodipt" "gruvbox" "half-life"
    "hotstick.minimal" "huvix" "json" "lambda" "larserikfinholt"
    "marcduiker" "material" "montys" "multiverse-neon"
    "pararussel" "powerline" "probua.minimal"
    "pure" "robbyrussell" "sorin" "space" "spaceship" "star"
    "stelbent-compact.minimal" "the-unnamed" "tokyonight_storm"
    "tonybaloney" "wholespace" "ys" "zash"
)

set_omp_theme() {
    local name="$1"
    local theme_file="$POSH_THEMES_PATH/$name.omp.json"

    if command -v oh-my-posh &>/dev/null && [[ -f "$theme_file" ]]; then
        eval "$(oh-my-posh init zsh --config "$theme_file")"
        return 0
    fi
    return 1
}

# Select and apply a random theme
if [[ -n "$POSH_THEMES_PATH" && -d "$POSH_THEMES_PATH" ]]; then
    RANDOM_THEME=${MY_THEMES[$((RANDOM % ${#MY_THEMES[@]}))]}
    echo "Theme: $RANDOM_THEME"
    if ! set_omp_theme "$RANDOM_THEME"; then
        # Fallback to starship
        if command -v starship &>/dev/null; then
            eval "$(starship init zsh)"
        fi
    fi
elif command -v starship &>/dev/null; then
    eval "$(starship init zsh)"
fi

#----------------------------------------------------------------------
# Section: Aliases
#----------------------------------------------------------------------

# Git aliases (from modules)
if [[ "${LOAD_GIT_TOOLS:-true}" == "true" ]]; then
    alias cugb='clear_git_branch'
    alias ccppr='cherry_pick_pr'
fi

# Utility aliases (from modules)
if [[ "${LOAD_UTILITY_TOOLS:-true}" == "true" ]]; then
    alias upall='update_all'
    alias ohis='open_shell_history'
    alias printenv='env | sort'
    alias chst='check_website_status'
    alias wimi='get_public_ip'
    alias spath='show_path'
fi

# General aliases
alias ll='ls -lah'
alias la='ls -la'
alias l='ls -l'

# Use lsd if available
if command -v lsd &>/dev/null; then
    alias ls='lsd'
fi

# Use bat if available
if command -v bat &>/dev/null; then
    alias cat='bat --paging=never'
fi

# kubectl alias
if command -v kubectl &>/dev/null; then
    alias k='kubectl'
fi

#----------------------------------------------------------------------
# Section: Finalization
#----------------------------------------------------------------------

# Display load time
PROFILE_LOAD_END=$EPOCHREALTIME
if [[ -n "$PROFILE_LOAD_START" && -n "$PROFILE_LOAD_END" ]]; then
    LOAD_TIME_MS=$(( (PROFILE_LOAD_END - PROFILE_LOAD_START) * 1000 ))
    printf "Profile loaded in %.0fms\n" "$LOAD_TIME_MS"
fi

# Show system info (10% chance, large terminal only)
if command -v fastfetch &>/dev/null; then
    if (( RANDOM % 10 == 0 )) && (( COLUMNS >= 120 )) && (( LINES >= 32 )); then
        fastfetch
    fi
fi

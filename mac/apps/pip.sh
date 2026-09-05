#!/usr/bin/env bash
# Python package installation script (uses pipx for CLI tools)
# Must be sourced from setup.sh (requires the info, command_exists and error helpers)

info "Installing Applications from pip..."

# CLI tools - installed via pipx (each gets its own venv)
PIPX_PACKAGES=(
    "glances"
    "git-fame"
    "fava"
    "git-playback"  # https://github.com/jianli/git-playback
)

if command_exists pipx; then
    PIPX_INSTALLED="$(pipx list --short 2>/dev/null)"
    for pkg in "${PIPX_PACKAGES[@]}"; do
        if printf '%s\n' "$PIPX_INSTALLED" | grep -q "^${pkg} "; then
            echo -e "  \033[90m$pkg (already installed)\033[0m"
        else
            echo -e "  Installing \033[32m$pkg\033[0m..."
            pipx install "$pkg" 2>/dev/null || echo -e "  \033[31mFailed to install $pkg\033[0m"
        fi
    done
else
    error "pipx is not installed. Run: brew install pipx"
fi

# pipx install git+https://github.com/beancount/beanprice.git
# pipx install pricehist

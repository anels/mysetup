#!/usr/bin/env bash
# VS Code extension installation script
# Must be sourced from setup.sh (requires command_exists, error helpers)

if ! type command_exists &>/dev/null; then
    echo "Error: vscode.sh must be sourced from setup.sh" >&2
    return 2>/dev/null || exit 1
fi

echo -e "\033[32mInstalling VS Code Extensions...\033[0m"

if ! command_exists code; then
    error "VS Code is not installed."
    return 0
fi

# Extensions that only make sense on macOS; the rest are shared with Windows
EXTENSIONS=(
    "formulahendry.code-runner"
    "github.vscode-github-actions"
    "gruntfuggly.todo-tree"
)

SHARED_EXTENSIONS_FILE="$SCRIPT_DIR/../common/vscode/extensions.txt"
if [[ -f "$SHARED_EXTENSIONS_FILE" ]]; then
    while IFS= read -r line; do
        line="${line%%#*}"
        line="${line// /}"
        [[ -n "$line" ]] && EXTENSIONS+=("$line")
    done < "$SHARED_EXTENSIONS_FILE"
else
    error "Shared extension list not found: $SHARED_EXTENSIONS_FILE"
fi

# Match against one lowercased blob instead of grepping once per extension
INSTALLED_EXTENSIONS=$'\n'"$(code --list-extensions 2>/dev/null | tr '[:upper:]' '[:lower:]')"$'\n'

for ext in "${EXTENSIONS[@]}"; do
    if [[ "$INSTALLED_EXTENSIONS" == *$'\n'"$ext"$'\n'* ]]; then
        echo -e "  \033[90m$ext (already installed)\033[0m"
    else
        echo -ne "  Installing $ext..."
        if code --install-extension "$ext" --force &>/dev/null; then
            echo -e " \033[32mOK\033[0m"
        else
            echo -e " \033[31mFAILED\033[0m"
        fi
    fi
done

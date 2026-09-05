#!/usr/bin/env bash
# LookerTools — fetch Looker JAR + dependencies from apidownload.looker.com
# Public functions: save_looker_jar, invoke_looker_download

_LOOKER_MAX_PROMPT_ATTEMPTS=3

# Prompt user for a value with retries and validation.
# Args: <var_name> <prompt> [validator_regex]
# Returns 0 on success, 1 on max attempts, 2 on user cancel.
_looker_prompt() {
    local var="$1" prompt="$2" pattern="${3:-}"
    local attempt=0 value
    while (( attempt < _LOOKER_MAX_PROMPT_ATTEMPTS )); do
        ((attempt++))
        (( attempt > 1 )) && echo "Attempt $attempt of $_LOOKER_MAX_PROMPT_ATTEMPTS"
        read -r "value?$prompt (or 'cancel' to abort): "
        [[ "$value" == "cancel" ]] && echo "Operation cancelled." && return 2
        if [[ -n "$value" ]] && [[ -z "$pattern" || "$value" =~ $pattern ]]; then
            printf -v "$var" '%s' "$value"
            return 0
        fi
        echo "Error: invalid input." >&2
    done
    return 1
}

save_looker_jar() {
    # Usage: save_looker_jar <version> <license> <email>
    local LOOKER_VERSION="$1" LOOKER_LICENSE="$2" LOOKER_EMAIL="$3"

    # Use a temp file — storing the response in a variable corrupts embedded \n in sha256 fields
    local tmp_response
    tmp_response=$(mktemp)
    trap 'rm -f "$tmp_response"' RETURN

    curl -fsS -X POST \
        -H "Content-Type: application/json" \
        -d "{\"lic\": \"$LOOKER_LICENSE\", \"email\": \"$LOOKER_EMAIL\", \"latest\": \"specific\", \"specific\": \"looker-$LOOKER_VERSION-latest.jar\"}" \
        "https://apidownload.looker.com/download" > "$tmp_response" || {
            echo "Error: download API request failed." >&2
            return 1
        }

    local version_text
    version_text=$(jq -r '.version_text // empty' "$tmp_response" 2>/dev/null)
    if [[ -z "$version_text" ]]; then
        echo "Error: No such version $LOOKER_VERSION." >&2
        return 1
    fi

    local latest_version="${version_text%.jar}"
    if [[ -d "$latest_version" ]]; then
        echo "The version $latest_version is already downloaded."
        return 0
    fi

    mkdir -p "$latest_version"
    local url dep_url
    url=$(jq -r '.url' "$tmp_response")
    dep_url=$(jq -r '.depUrl' "$tmp_response")

    echo "Downloading looker.jar to \"$latest_version\""
    curl -fL -o "$latest_version/looker.jar" "$url" || return 1
    echo "Downloading looker-dependencies.jar to \"$latest_version\""
    curl -fL -o "$latest_version/looker-dependencies.jar" "$dep_url" || return 1
}

invoke_looker_download() {
    # Usage: invoke_looker_download [version] [license] [email]
    local LOOKER_VERSION="${1:-25.6}"
    local LOOKER_LICENSE="${2:-${LOOKER_LICENSE_KEY:-}}"
    local LOOKER_EMAIL="${3:-${LOOKER_LICENSE_EMAIL:-}}"
    local rc

    if [[ -z "$LOOKER_LICENSE" ]]; then
        echo "Looker license key required but not found." >&2
        echo "Add to ~/.zshrc.local to skip prompt: export LOOKER_LICENSE_KEY='...'" >&2
        _looker_prompt LOOKER_LICENSE "Please enter your Looker license key"
        rc=$?
        (( rc == 2 )) && return 0
        (( rc != 0 )) && return 1
    fi

    if [[ -z "$LOOKER_EMAIL" ]]; then
        echo "Looker license email required but not found." >&2
        echo "Add to ~/.zshrc.local to skip prompt: export LOOKER_LICENSE_EMAIL='...'" >&2
        _looker_prompt LOOKER_EMAIL "Please enter your Looker license email" '^[^@]+@[^@]+\.[^@]+$'
        rc=$?
        (( rc == 2 )) && return 0
        (( rc != 0 )) && return 1
    fi

    mkdir -p ~/LookerJar
    (
        cd ~/LookerJar || exit 1
        echo "Downloading Looker version $LOOKER_VERSION..."
        save_looker_jar "$LOOKER_VERSION" "$LOOKER_LICENSE" "$LOOKER_EMAIL"
    )
}

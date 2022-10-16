#!/usr/bin/env bash
# UtilityTools Module - Contains utility functions for macOS/Linux

measure_command() {
    # Usage: measure_command <samples> <command...>
    # Example: measure_command 3 sleep 0.1
    local samples="${1:-1}"
    shift
    local cmd=("$@")

    if [[ ${#cmd[@]} -eq 0 ]]; then
        echo "Usage: measure_command <samples> <command...>"
        return 1
    fi

    local total_ms=0
    local min_ms=999999999
    local max_ms=0

    for ((i = 1; i <= samples; i++)); do
        local start end elapsed_ms
        if [[ -n "$EPOCHREALTIME" ]]; then
            start=$EPOCHREALTIME
            "${cmd[@]}"
            end=$EPOCHREALTIME
            elapsed_ms=$(( (end - start) * 1000 ))
        else
            start=$(date +%s%N 2>/dev/null || python3 -c 'import time; print(int(time.time()*1e9))')
            "${cmd[@]}"
            end=$(date +%s%N 2>/dev/null || python3 -c 'import time; print(int(time.time()*1e9))')
            elapsed_ms=$(( (end - start) / 1000000 ))
        fi
        total_ms=$((total_ms + elapsed_ms))

        ((elapsed_ms < min_ms)) && min_ms=$elapsed_ms
        ((elapsed_ms > max_ms)) && max_ms=$elapsed_ms
    done

    local avg_ms=$((total_ms / samples))
    echo ""
    echo "Avg: ${avg_ms}ms"
    echo "Min: ${min_ms}ms"
    echo "Max: ${max_ms}ms"
}

update_all() {
    echo -e "\n\033[32mUpdate Homebrew...\033[0m"
    brew update
    brew upgrade
    brew cleanup

    if command -v tldr &>/dev/null; then
        echo -e "\n\033[32mUpdate tldr...\033[0m"
        tldr --update
    fi

    if command -v mas &>/dev/null; then
        echo -e "\n\033[32mUpdate Mac App Store apps...\033[0m"
        mas upgrade
    fi
}

open_shell_history() {
    local hist_file="${HISTFILE:-$HOME/.zsh_history}"
    if command -v vim &>/dev/null; then
        vim "+set nowrap" "+normal G$" "$hist_file"
    else
        less "$hist_file"
    fi
}

get_public_ip() {
    local ip
    ip="$(curl -s http://ifconfig.me/ip)"
    echo "$ip"
    # Copy to clipboard on macOS
    if command -v pbcopy &>/dev/null; then
        echo -n "$ip" | pbcopy
        echo "(copied to clipboard)"
    fi
}

check_website_status() {
    # Usage: check_website_status <url>
    local url="$1"

    if [[ -z "$url" ]]; then
        echo "Usage: check_website_status <url>"
        return 1
    fi

    local prev_200_time
    prev_200_time=$(date +%s)

    echo "Monitoring $url (Ctrl+C to stop)..."
    while true; do
        local cur_time cur_epoch status_code
        cur_time="$(date '+%Y-%m-%d %H:%M:%S')"
        cur_epoch=$(date +%s)

        status_code=$(curl -s -o /dev/null -w "%{http_code}" "$url" 2>/dev/null || echo "000")

        printf "%s - " "$cur_time"
        if [[ "$status_code" == "200" ]]; then
            local elapsed=$((cur_epoch - prev_200_time))
            echo -e "\033[32mStatus code: $status_code\033[0m -- Time since last 200: ${elapsed}s"
            prev_200_time=$cur_epoch
        elif [[ "$status_code" == "000" ]]; then
            echo -e "\033[33mFailed to connect\033[0m"
        else
            echo -e "\033[31mStatus code: $status_code\033[0m"
        fi

        sleep 5
    done
}

show_path() {
    echo "$PATH" | tr ':' '\n'
}


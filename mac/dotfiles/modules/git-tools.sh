#!/usr/bin/env bash
# GitTools Module - Contains git-related functions for macOS/Linux

cherry_pick_pr() {
    # Usage: cherry_pick_pr <commit_hash> <destination_branch>
    local commit_to_cherry_pick="$1"
    local destination_branch="$2"

    if [[ -z "$commit_to_cherry_pick" || -z "$destination_branch" ]]; then
        echo "Usage: cherry_pick_pr <commit_hash> <destination_branch>"
        return 1
    fi

    # Get current branch name
    local current_branch
    current_branch="$(git rev-parse --abbrev-ref HEAD)"
    echo "You are currently on branch $current_branch"

    # Validate commit hash length
    if [[ ${#commit_to_cherry_pick} -lt 4 ]]; then
        echo "Error: Commit hash must be at least 4 characters." >&2
        return 1
    fi

    # Take only first 7 characters of commit hash
    commit_to_cherry_pick="${commit_to_cherry_pick:0:7}"

    # Get new commits
    git fetch --all

    # Get commit message
    local commit_message
    commit_message="$(git log --format=%B -n 1 "$commit_to_cherry_pick" | head -1)"

    # Sanitize destination branch name for branch naming
    local destination_branch_name
    destination_branch_name="$(echo "$destination_branch" | sed 's/[^a-zA-Z0-9._]//g')"

    # Generate new branch name
    local new_branch_name="cp/${commit_to_cherry_pick}-to-${destination_branch_name}"

    # Create PR title
    local pr_title="Cherry-Pick: $commit_message -> $destination_branch"
    echo "Title: '$pr_title'"

    # Cherry-pick commit to new branch
    if ! git checkout "$destination_branch"; then
        echo "Error: Failed to checkout branch $destination_branch" >&2
        return 1
    fi

    if ! git pull; then
        echo "Error: Failed to pull branch $destination_branch" >&2
        git checkout "$current_branch"
        return 1
    fi

    if ! git checkout -b "$new_branch_name"; then
        echo "Error: Failed to create new branch $new_branch_name" >&2
        git checkout "$current_branch"
        return 1
    fi

    if ! git cherry-pick -x "$commit_to_cherry_pick"; then
        echo "Conflict occurred during cherry-pick. Resolve the conflict and then commit the cherry-pick changes."
        echo "----------------------------------------------------------------------"
        echo "    git cherry-pick --continue"
        echo "----------------------------------------------------------------------"
        echo "Then, you can push the branch to github and create PR manually by:"
        echo "----------------------------------------------------------------------"
        echo "    git push origin $new_branch_name --force && gh pr create --base $destination_branch --title '$pr_title' --fill"
        echo "----------------------------------------------------------------------"
        return 1
    fi

    # Push the new branch
    git push origin "$new_branch_name" --force

    echo "Create PR by 'gh pr create --base $destination_branch --title \"$pr_title\" --fill'"
    gh pr create --base "$destination_branch" --title "$pr_title" --fill

    # Switch back to the initial branch
    git checkout "$current_branch"
}

clear_git_branch() {
    if ! git rev-parse --is-inside-work-tree &>/dev/null; then
        echo "Not in a valid git repo. Please run this command inside a git repo."
        return 1
    fi

    local default_branch
    default_branch="$(git symbolic-ref refs/remotes/origin/HEAD 2>/dev/null | sed 's|^refs/remotes/origin/||')"

    if [[ -z "$default_branch" ]]; then
        echo "Error: Cannot determine default branch. Try: git remote set-head origin --auto" >&2
        return 1
    fi

    git checkout "$default_branch"
    git pull

    # Delete all local branches except develop, main, master
    git branch | sed 's/^[* ]*//' | grep -vE '^(develop|main|master)$' | while read -r branch; do
        git branch -D "$branch"
    done

    # Cleanup
    git repack
    git prune-packed
    git reflog expire --expire=1.month.ago
    git gc --aggressive
}

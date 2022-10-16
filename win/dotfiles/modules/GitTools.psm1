# GitTools Module - Contains git-related functions

# Renamed from Create-CherryPickPR to New-CherryPickPR to use an approved PowerShell verb
function New-CherryPickPR {
    param(
        [Parameter(Mandatory=$true)][string]$commitToCherryPick,
        [Parameter(Mandatory=$true)][string]$destinationBranch
    )

    try {
        # Get new commits
        git fetch --all

        # Get current branch name
        $currentBranch = git rev-parse --abbrev-ref HEAD
        Write-Output "You are currently on branch $currentBranch"

        # Validate commit hash length
        if ($commitToCherryPick.Length -lt 4) {
            Write-Error "Commit hash must be at least 4 characters."
            return
        }

        # Take only first 7 characters of commit hash
        $commitToCherryPick = $commitToCherryPick.substring(0,[Math]::Min(7, $commitToCherryPick.Length))

        # Get commit message
        $commitMessage = (git log --format=%B -n 1 $commitToCherryPick).Split("`n")[0]

        # Remove all special characters from $destinationBranch except "_", and ".".
        $destinationBranchName = $destinationBranch -replace '[^a-zA-Z0-9._]', ''

        # Generate new branch name based on commit hash and destinationBranch
        $newBranchName = "cp/$commitToCherryPick-to-$destinationBranchName"

        # Create a Pull Request against the destination branch using GitHub CLI 'gh'.
        $prTitle = "Cherry-Pick: $commitMessage -> $destinationBranch"
        Write-Output "Title: '$prTitle'"

        # Cherry-pick commit to new branch
        git checkout $destinationBranch
        if ($LASTEXITCODE -ne 0) {
            Write-Error "Failed to checkout branch $destinationBranch"
            return
        }
        git pull
        if ($LASTEXITCODE -ne 0) {
            Write-Error "Failed to pull branch $destinationBranch"
            git checkout $currentBranch
            return
        }
        git checkout -b $newBranchName
        if ($LASTEXITCODE -ne 0) {
            Write-Error "Failed to create new branch $newBranchName"
            git checkout $currentBranch
            return
        }
        git cherry-pick -x $commitToCherryPick

        # Check if the cherry-pick command was successful
        if ($LASTEXITCODE -ne 0) {
            Write-Output "Conflict occurred during cherry-pick. Resolve the conflict and then commit the cherry-pick changes."
            Write-Output "----------------------------------------------------------------------"
            Write-Output "    git cherry-pick --continue"
            Write-Output "----------------------------------------------------------------------"
            Write-Output "Then, you can push the branch to github and create PR manually by:"
            Write-Output "----------------------------------------------------------------------"
            Write-Output "    git push origin $newBranchName --force && gh pr create --base $destinationBranch --title '$prTitle' --fill"
            Write-Output "----------------------------------------------------------------------"
            git cherry-pick --abort
            git checkout $currentBranch
            return
        }

        # Push the new branch
        git push origin $newBranchName --force

        Write-Output "Create PR by 'gh pr create --base $destinationBranch --title $prTitle --fill'"
        gh pr create --base $destinationBranch --title $prTitle --fill
        # gh pr create --base $destinationBranch' --title '$prTitle' --body 'Cherry-pick from $commitToCherryPick: $commitMessage'

        # Switch back to the initial branch
        git checkout $currentBranch
    }
    catch {
        Write-Output $_.Exception.Message
    }
}

# Keep Create-CherryPickPR as an alias for backward compatibility
New-Alias -Name Create-CherryPickPR -Value New-CherryPickPR

# Renamed from Cleanup-GitBranch to Clear-GitBranch to use an approved PowerShell verb
function Clear-GitBranch {
    $null = git rev-parse --is-inside-work-tree 2>&1
    if ($LASTEXITCODE -ne 0) {
        Write-Host "Not in a valid git repo. Please run this command inside a git repo."
        return
    }
    git checkout $($(git symbolic-ref refs/remotes/origin/HEAD) -replace "^refs/remotes/origin/", "")
    git pull
    # do actual thing
    git branch | % { $_.Trim() } | ? { $_ -notmatch '^\*|(develop|main|master)$' } | % { git branch -D $_ }
    # see https://gitbetter.substack.com/p/how-to-clean-up-the-git-repo-and
    # git remote prune origin
    git repack
    git prune-packed
    git reflog expire --expire=1.month.ago
    git gc --aggressive
}

# Keep Cleanup-GitBranch as an alias for backward compatibility
New-Alias -Name Cleanup-GitBranch -Value Clear-GitBranch

# Make sure to explicitly export the functions so they're available when imported
Export-ModuleMember -Function New-CherryPickPR, Clear-GitBranch -Alias Create-CherryPickPR, Cleanup-GitBranch

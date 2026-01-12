# PowerShell script to delete a pull request and optionally its branch
# Usage: .\scripts\delete_pr.ps1 <pr-number> [-DeleteBranch]

param(
    [Parameter(Mandatory=$true, Position=0)]
    [int]$PRNumber,

    [switch]$DeleteBranch
)

$ErrorActionPreference = "Stop"

# Load environment variables from .env file
if (Test-Path ".env") {
    Get-Content ".env" | ForEach-Object {
        if ($_ -match "^([^#][^=]+)=(.*)$") {
            Set-Item -Path "env:$($matches[1])" -Value $matches[2]
        }
    }
}

# Get repository URL from git remote
$GitHubRepoUrl = git remote get-url origin 2>$null
if (-not $GitHubRepoUrl) {
    Write-Host "Error: Not in a git repository or no 'origin' remote found" -ForegroundColor Red
    exit 1
}

# Extract repo path from URL
$RepoPath = $GitHubRepoUrl -replace "https://github.com/", "" -replace "\.git$", ""

# Set GitHub token for gh CLI if available
if ($env:GITHUB_PAT) {
    $env:GH_TOKEN = $env:GITHUB_PAT
}

Write-Host "Fetching PR #$PRNumber details..."

# Get PR details including branch name
$PRInfo = gh pr view $PRNumber -R $RepoPath --json number,title,state,headRefName 2>$null | ConvertFrom-Json

if (-not $PRInfo) {
    Write-Host "Error: PR #$PRNumber not found in $RepoPath" -ForegroundColor Red
    exit 1
}

# Extract PR details
$PRTitle = $PRInfo.title
$PRState = $PRInfo.state
$PRBranch = $PRInfo.headRefName

Write-Host "PR #${PRNumber}: $PRTitle"
Write-Host "State: $PRState"
Write-Host "Branch: $PRBranch"

# Confirm deletion
Write-Host ""
if ($DeleteBranch) {
    Write-Host "WARNING: This will close PR #$PRNumber and DELETE branch '$PRBranch'" -ForegroundColor Yellow
} else {
    Write-Host "WARNING: This will close PR #$PRNumber (branch will be kept)" -ForegroundColor Yellow
}

$confirmation = Read-Host "Are you sure? (y/N)"
if ($confirmation -ne 'y' -and $confirmation -ne 'Y') {
    Write-Host "Cancelled"
    exit 0
}

# Close the PR if it's open
if ($PRState -eq "OPEN") {
    Write-Host "Closing PR #$PRNumber..."
    gh pr close $PRNumber -R $RepoPath
} else {
    Write-Host "PR is already closed"
}

# Delete the branch if requested
if ($DeleteBranch) {
    Write-Host "Deleting branch '$PRBranch'..."

    # Delete remote branch
    git push origin --delete $PRBranch 2>$null
    if (-not $?) {
        Write-Host "Note: Could not delete remote branch (may already be deleted)" -ForegroundColor Yellow
    }

    # Delete local branch if it exists
    $localBranch = git show-ref --verify --quiet "refs/heads/$PRBranch" 2>$null
    if ($LASTEXITCODE -eq 0) {
        # Make sure we're not on the branch we're trying to delete
        $currentBranch = git branch --show-current
        if ($currentBranch -eq $PRBranch) {
            Write-Host "Switching to main branch first..."
            git checkout main
        }
        git branch -D $PRBranch 2>$null
        if (-not $?) {
            Write-Host "Note: Could not delete local branch" -ForegroundColor Yellow
        }
    }

    Write-Host "Successfully closed PR #$PRNumber and deleted branch '$PRBranch'" -ForegroundColor Green
} else {
    Write-Host "Successfully closed PR #$PRNumber (branch kept: '$PRBranch')" -ForegroundColor Green
}

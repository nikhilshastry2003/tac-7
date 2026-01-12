# PowerShell script to clear all comments from a GitHub issue
# Usage: .\scripts\clear_issue_comments.ps1 <issue-number>

param(
    [Parameter(Mandatory=$true, Position=0)]
    [int]$IssueNumber
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

Write-Host "Fetching comments for issue #$IssueNumber in $RepoPath..."

# Get all comment IDs for the issue
$CommentIds = gh api "repos/$RepoPath/issues/$IssueNumber/comments" --jq '.[].id' 2>$null

if (-not $CommentIds) {
    Write-Host "No comments found on issue #$IssueNumber"
    exit 0
}

# Count comments
$CommentArray = $CommentIds -split "`n" | Where-Object { $_ }
$CommentCount = $CommentArray.Count
Write-Host "Found $CommentCount comment(s) to delete"

# Delete each comment
foreach ($CommentId in $CommentArray) {
    Write-Host "Deleting comment $CommentId..."
    gh api --method DELETE "repos/$RepoPath/issues/comments/$CommentId" 2>$null
    if (-not $?) {
        Write-Host "Failed to delete comment $CommentId" -ForegroundColor Yellow
    }
}

Write-Host "Successfully deleted all comments from issue #$IssueNumber" -ForegroundColor Green

# PowerShell script to purge worktree for ADW
# Usage: .\scripts\purge_tree.ps1 <ADW_ID> [-KeepBranch]

param(
    [Parameter(Mandatory=$true, Position=0)]
    [string]$AdwId,

    [switch]$KeepBranch
)

$DeleteBranch = -not $KeepBranch

Write-Host "Purging worktree for $AdwId..." -ForegroundColor Blue
Write-Host ""

# Get worktree path
$WorktreePath = "trees\$AdwId"

# Check if worktree exists
if (-not (Test-Path $WorktreePath)) {
    Write-Host "Warning: Worktree directory not found at $WorktreePath" -ForegroundColor Yellow
} else {
    Write-Host "Found worktree at: $WorktreePath" -ForegroundColor Green
}

# Get branch name from worktree (if it exists in git)
$BranchName = $null
$worktreeList = git worktree list --porcelain 2>$null
if ($worktreeList) {
    $worktreeLines = $worktreeList -split "`n"
    for ($i = 0; $i -lt $worktreeLines.Count; $i++) {
        if ($worktreeLines[$i] -like "*$WorktreePath*") {
            for ($j = $i; $j -lt [Math]::Min($i + 5, $worktreeLines.Count); $j++) {
                if ($worktreeLines[$j] -match "^branch refs/heads/(.+)$") {
                    $BranchName = $matches[1]
                    break
                }
            }
            break
        }
    }
}

# If we couldn't get it from worktree list, try to infer from ADW ID
if (-not $BranchName) {
    $AdwIdLower = $AdwId.ToLower()
    $possibleBranches = git branch -a 2>$null | Where-Object { $_ -match "adw-$AdwIdLower" -and $_ -notmatch "remotes/" } | ForEach-Object { $_.Trim().TrimStart("* ") }

    if ($possibleBranches) {
        if ($possibleBranches -is [array]) {
            if ($possibleBranches.Count -eq 1) {
                $BranchName = $possibleBranches[0]
                Write-Host "Inferred branch from ADW ID: $BranchName" -ForegroundColor Yellow
            } else {
                Write-Host "Found multiple branches containing ADW ID:" -ForegroundColor Yellow
                $possibleBranches | ForEach-Object { Write-Host "  $_" }
                Write-Host "Will not delete any branch (ambiguous)" -ForegroundColor Yellow
                $DeleteBranch = $false
            }
        } else {
            $BranchName = $possibleBranches
            Write-Host "Inferred branch from ADW ID: $BranchName" -ForegroundColor Yellow
        }
    } else {
        Write-Host "Warning: Could not determine branch name" -ForegroundColor Yellow
    }
} else {
    Write-Host "Associated branch: $BranchName" -ForegroundColor Green
}

# Kill any processes using ports for this ADW
Write-Host ""
Write-Host "Checking for processes on ADW ports..." -ForegroundColor Green

# Calculate ports (same hash-based logic as Python)
$md5 = [System.Security.Cryptography.MD5]::Create()
$bytes = [System.Text.Encoding]::UTF8.GetBytes($AdwId)
$hash = $md5.ComputeHash($bytes)
$hashHex = [BitConverter]::ToString($hash).Replace("-", "").Substring(0, 8)
$portOffset = [Convert]::ToInt32($hashHex, 16) % 15
$backendPort = 9100 + $portOffset
$frontendPort = 9200 + $portOffset

# Kill backend process
$backendConn = Get-NetTCPConnection -LocalPort $backendPort -ErrorAction SilentlyContinue
if ($backendConn) {
    Stop-Process -Id $backendConn.OwningProcess -Force -ErrorAction SilentlyContinue
    Write-Host "  Killed process on backend port $backendPort" -ForegroundColor Yellow
} else {
    Write-Host "  No process on backend port $backendPort" -ForegroundColor Green
}

# Kill frontend process
$frontendConn = Get-NetTCPConnection -LocalPort $frontendPort -ErrorAction SilentlyContinue
if ($frontendConn) {
    Stop-Process -Id $frontendConn.OwningProcess -Force -ErrorAction SilentlyContinue
    Write-Host "  Killed process on frontend port $frontendPort" -ForegroundColor Yellow
} else {
    Write-Host "  No process on frontend port $frontendPort" -ForegroundColor Green
}

# Remove worktree
Write-Host ""
Write-Host "Removing worktree..." -ForegroundColor Green
$worktreeInGit = git worktree list 2>$null | Where-Object { $_ -like "*$WorktreePath*" }
if ($worktreeInGit) {
    git worktree remove -f $WorktreePath 2>$null
    if ($LASTEXITCODE -eq 0) {
        Write-Host "  Worktree removed from git" -ForegroundColor Green
    } else {
        Write-Host "  Failed to remove worktree from git" -ForegroundColor Red
        git worktree prune
    }
} else {
    Write-Host "  Worktree not registered in git" -ForegroundColor Yellow
}

# Remove directory if it still exists
if (Test-Path $WorktreePath) {
    Remove-Item -Path $WorktreePath -Recurse -Force
    Write-Host "  Worktree directory removed" -ForegroundColor Green
}

# Handle branch deletion
if ($DeleteBranch -and $BranchName) {
    Write-Host ""
    Write-Host "Deleting branch: $BranchName" -ForegroundColor Green

    # Check if we're currently on this branch
    $currentBranch = git branch --show-current
    if ($currentBranch -eq $BranchName) {
        Write-Host "  Switching to main branch first..." -ForegroundColor Yellow
        git checkout main
    }

    # Delete local branch
    git branch -D $BranchName 2>$null
    if ($LASTEXITCODE -eq 0) {
        Write-Host "  Local branch deleted" -ForegroundColor Green
    } else {
        Write-Host "  Could not delete local branch (may not exist)" -ForegroundColor Yellow
    }

    # Note about remote branch
    Write-Host "  Note: Remote branch not deleted. To delete it, run:" -ForegroundColor Yellow
    Write-Host "    git push origin --delete $BranchName" -ForegroundColor Blue
}

# Clean up any stale worktree entries
git worktree prune

Write-Host ""
Write-Host "Purge complete for $AdwId" -ForegroundColor Green

# Show summary
Write-Host ""
Write-Host "Summary:" -ForegroundColor Blue
Write-Host "  ADW ID: $AdwId"
Write-Host "  Worktree path: $WorktreePath"
if ($BranchName) { Write-Host "  Branch: $BranchName" }
Write-Host "  Backend port: $backendPort"
Write-Host "  Frontend port: $frontendPort"

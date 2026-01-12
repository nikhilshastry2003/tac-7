# PowerShell script to check ADW and Application Ports

Write-Host "Checking ADW and Application Ports..." -ForegroundColor Blue
Write-Host ""

# Function to check port status
function Check-Port {
    param([int]$Port)

    $connection = Get-NetTCPConnection -LocalPort $Port -ErrorAction SilentlyContinue
    if ($connection) {
        $process = Get-Process -Id $connection.OwningProcess -ErrorAction SilentlyContinue
        if ($process) {
            return @{
                InUse = $true
                PID = $process.Id
                Process = $process.Name
            }
        }
    }
    return @{ InUse = $false }
}

# Check main application ports
Write-Host "Main Application Ports:" -ForegroundColor Green
@(5173, 8000, 8001) | ForEach-Object {
    $status = Check-Port -Port $_
    if ($status.InUse) {
        Write-Host "  Port ${_}: IN USE (PID: $($status.PID), Process: $($status.Process))" -ForegroundColor Red
    } else {
        Write-Host "  Port ${_}: Available" -ForegroundColor Green
    }
}

Write-Host ""

# Check isolated ADW backend ports
Write-Host "Isolated ADW Backend Ports (9100-9114):" -ForegroundColor Green
$inUseCount = 0
9100..9114 | ForEach-Object {
    $status = Check-Port -Port $_
    if ($status.InUse) {
        Write-Host "  Port ${_}: IN USE (PID: $($status.PID), Process: $($status.Process))" -ForegroundColor Red
        $inUseCount++
    }
}
if ($inUseCount -eq 0) {
    Write-Host "  All backend ports available" -ForegroundColor Green
}

Write-Host ""

# Check isolated ADW frontend ports
Write-Host "Isolated ADW Frontend Ports (9200-9214):" -ForegroundColor Green
$inUseCount = 0
9200..9214 | ForEach-Object {
    $status = Check-Port -Port $_
    if ($status.InUse) {
        Write-Host "  Port ${_}: IN USE (PID: $($status.PID), Process: $($status.Process))" -ForegroundColor Red
        $inUseCount++
    }
}
if ($inUseCount -eq 0) {
    Write-Host "  All frontend ports available" -ForegroundColor Green
}

Write-Host ""

# Show any active worktrees
Write-Host "Active Git Worktrees:" -ForegroundColor Green
$worktrees = git worktree list 2>$null | Where-Object { $_ -like "*trees*" }
if ($worktrees) {
    $worktrees | ForEach-Object {
        Write-Host "  $_" -ForegroundColor Yellow
    }
} else {
    Write-Host "  No isolated worktrees found" -ForegroundColor Green
}

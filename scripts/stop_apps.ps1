# PowerShell script to stop Natural Language SQL Interface and ADW Services

Write-Host "Stopping Natural Language SQL Interface and ADW Services..." -ForegroundColor Blue

# Kill any running PowerShell start scripts
Write-Host "Killing start script processes..." -ForegroundColor Green
Get-Process -Name "pwsh", "powershell" -ErrorAction SilentlyContinue | Where-Object {
    $_.MainWindowTitle -like "*start.ps1*"
} | Stop-Process -Force -ErrorAction SilentlyContinue

# Function to kill processes on a port
function Kill-ProcessOnPort {
    param([int]$Port)

    $connections = Get-NetTCPConnection -LocalPort $Port -ErrorAction SilentlyContinue
    if ($connections) {
        foreach ($conn in $connections) {
            $process = Get-Process -Id $conn.OwningProcess -ErrorAction SilentlyContinue
            if ($process -and $process.Name -ne "System") {
                Stop-Process -Id $process.Id -Force -ErrorAction SilentlyContinue
                Write-Host "  Killed process on port $Port (PID: $($process.Id))" -ForegroundColor Yellow
            }
        }
    }
}

# Kill processes on main ports
Write-Host "Killing processes on main ports (5173, 8000, 8001)..." -ForegroundColor Green
@(5173, 8000, 8001) | ForEach-Object { Kill-ProcessOnPort -Port $_ }

# Kill processes on isolated ADW backend ports
Write-Host "Killing processes on isolated ADW backend ports (9100-9114)..." -ForegroundColor Green
9100..9114 | ForEach-Object { Kill-ProcessOnPort -Port $_ }

# Kill processes on isolated ADW frontend ports
Write-Host "Killing processes on isolated ADW frontend ports (9200-9214)..." -ForegroundColor Green
9200..9214 | ForEach-Object { Kill-ProcessOnPort -Port $_ }

# Kill any uvicorn or node processes that might be hanging
Write-Host "Killing any remaining uvicorn processes..." -ForegroundColor Green
Get-Process -Name "python" -ErrorAction SilentlyContinue | Where-Object {
    $_.CommandLine -like "*uvicorn*"
} | Stop-Process -Force -ErrorAction SilentlyContinue

Write-Host "Killing any remaining node/vite processes..." -ForegroundColor Green
Get-Process -Name "node" -ErrorAction SilentlyContinue | Stop-Process -Force -ErrorAction SilentlyContinue

Write-Host "All services stopped successfully!" -ForegroundColor Green

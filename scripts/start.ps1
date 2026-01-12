# PowerShell script to start the Natural Language SQL Interface

# Source port configuration if exists
if (Test-Path ".ports.env") {
    Get-Content ".ports.env" | ForEach-Object {
        if ($_ -match "^([^=]+)=(.*)$") {
            Set-Item -Path "env:$($matches[1])" -Value $matches[2]
        }
    }
}

# Port configuration with fallbacks
$SERVER_PORT = if ($env:BACKEND_PORT) { $env:BACKEND_PORT } else { 8000 }
$CLIENT_PORT = if ($env:FRONTEND_PORT) { $env:FRONTEND_PORT } else { 5173 }

Write-Host "Starting Natural Language SQL Interface..." -ForegroundColor Blue

# Function to kill process on port
function Kill-Port {
    param([int]$Port, [string]$ProcessName)

    $connections = Get-NetTCPConnection -LocalPort $Port -ErrorAction SilentlyContinue
    if ($connections) {
        foreach ($conn in $connections) {
            $process = Get-Process -Id $conn.OwningProcess -ErrorAction SilentlyContinue
            if ($process) {
                Write-Host "Found $ProcessName running on port $Port (PID: $($process.Id)). Killing it..." -ForegroundColor Yellow
                Stop-Process -Id $process.Id -Force -ErrorAction SilentlyContinue
                Start-Sleep -Seconds 1
                Write-Host "$ProcessName on port $Port has been terminated." -ForegroundColor Green
            }
        }
    }
}

# Kill any existing processes on our ports
Kill-Port -Port $SERVER_PORT -ProcessName "backend server"
Kill-Port -Port $CLIENT_PORT -ProcessName "frontend server"

# Get the script's directory
$SCRIPT_DIR = Split-Path -Parent $MyInvocation.MyCommand.Path
$PROJECT_ROOT = Split-Path -Parent $SCRIPT_DIR

# Check if .env exists in server directory
if (-not (Test-Path "$PROJECT_ROOT\app\server\.env")) {
    Write-Host "Warning: No .env file found in app\server\." -ForegroundColor Red
    Write-Host "Please:"
    Write-Host "  1. cd app\server"
    Write-Host "  2. copy .env.sample .env"
    Write-Host "  3. Edit .env and add your API keys"
    exit 1
}

# Start backend
Write-Host "Starting backend server..." -ForegroundColor Green
$backendJob = Start-Job -ScriptBlock {
    param($root)
    Set-Location "$root\app\server"
    uv run python server.py
} -ArgumentList $PROJECT_ROOT

# Wait for backend to start
Write-Host "Waiting for backend to start..."
Start-Sleep -Seconds 3

# Check if backend is running
$backendState = Get-Job -Id $backendJob.Id
if ($backendState.State -eq "Failed") {
    Write-Host "Backend failed to start!" -ForegroundColor Red
    exit 1
}

# Start frontend
Write-Host "Starting frontend server..." -ForegroundColor Green
$frontendJob = Start-Job -ScriptBlock {
    param($root)
    Set-Location "$root\app\client"
    npm run dev
} -ArgumentList $PROJECT_ROOT

# Wait for frontend to start
Start-Sleep -Seconds 3

# Check if frontend is running
$frontendState = Get-Job -Id $frontendJob.Id
if ($frontendState.State -eq "Failed") {
    Write-Host "Frontend failed to start!" -ForegroundColor Red
    exit 1
}

Write-Host "Services started successfully!" -ForegroundColor Green
Write-Host "Frontend: http://localhost:$CLIENT_PORT" -ForegroundColor Blue
Write-Host "Backend:  http://localhost:$SERVER_PORT" -ForegroundColor Blue
Write-Host "API Docs: http://localhost:$SERVER_PORT/docs" -ForegroundColor Blue
Write-Host ""
Write-Host "Press Ctrl+C to stop all services..."

# Wait for user to press Ctrl+C
try {
    while ($true) {
        Start-Sleep -Seconds 1
        # Check if jobs are still running
        if ((Get-Job -Id $backendJob.Id).State -ne "Running" -and
            (Get-Job -Id $frontendJob.Id).State -ne "Running") {
            break
        }
    }
}
finally {
    # Cleanup
    Write-Host "`nShutting down services..." -ForegroundColor Blue
    Stop-Job -Job $backendJob -ErrorAction SilentlyContinue
    Stop-Job -Job $frontendJob -ErrorAction SilentlyContinue
    Remove-Job -Job $backendJob -Force -ErrorAction SilentlyContinue
    Remove-Job -Job $frontendJob -Force -ErrorAction SilentlyContinue
    Write-Host "Services stopped successfully." -ForegroundColor Green
}

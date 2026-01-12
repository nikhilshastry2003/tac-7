# PowerShell script to kill the trigger_webhook.py process

Write-Host "Stopping trigger_webhook.py server..."

# Find and kill the process
$webhookProcess = Get-Process -Name "python" -ErrorAction SilentlyContinue | Where-Object {
    $_.CommandLine -like "*trigger_webhook.py*"
}

if ($webhookProcess) {
    Stop-Process -Id $webhookProcess.Id -Force -ErrorAction SilentlyContinue
    Write-Host "Webhook server stopped" -ForegroundColor Green
} else {
    Write-Host "No webhook server process found" -ForegroundColor Yellow
}

# Also check for any processes on port 8001
$port8001 = Get-NetTCPConnection -LocalPort 8001 -ErrorAction SilentlyContinue
if ($port8001) {
    Write-Host "Found process on port 8001, killing..."
    foreach ($conn in $port8001) {
        Stop-Process -Id $conn.OwningProcess -Force -ErrorAction SilentlyContinue
    }
    Write-Host "Port 8001 cleared" -ForegroundColor Green
}

Write-Host "Done."

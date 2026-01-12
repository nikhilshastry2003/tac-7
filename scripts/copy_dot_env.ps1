# PowerShell script to copy .env files from previous tac directory

# Check and copy root .env file
if (Test-Path "..\tac-6\.env") {
    Copy-Item -Path "..\tac-6\.env" -Destination ".env" -Force
    Write-Host "Successfully copied ..\tac-6\.env to .env" -ForegroundColor Green
} else {
    Write-Host "Warning: ..\tac-6\.env does not exist" -ForegroundColor Yellow
}

# Check and copy server .env file
if (Test-Path "..\tac-6\app\server\.env") {
    Copy-Item -Path "..\tac-6\app\server\.env" -Destination "app\server\.env" -Force
    Write-Host "Successfully copied ..\tac-6\app\server\.env to app\server\.env" -ForegroundColor Green
} else {
    Write-Host "Error: ..\tac-6\app\server\.env does not exist" -ForegroundColor Red
    exit 1
}

# PowerShell script to reset the database

Write-Host "Starting database reset..."

# Restore database from backup for testing
Write-Host "Copying backup.db to database.db..."
$backupPath = "app\server\db\backup.db"
$dbPath = "app\server\db\database.db"

try {
    Copy-Item -Path $backupPath -Destination $dbPath -Force -ErrorAction Stop
    Write-Host "Database reset successfully completed" -ForegroundColor Green
} catch {
    Write-Host "Error: Failed to reset database" -ForegroundColor Red
    Write-Host $_.Exception.Message
    exit 1
}

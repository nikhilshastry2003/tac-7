# PowerShell script to run Cloudflare tunnel to expose adws/trigger_webhook.py to the public internet
# Requires CLOUDFLARED_TUNNEL_TOKEN to be set in .env

# Load CLOUDFLARED_TUNNEL_TOKEN from .env file
if (Test-Path ".env") {
    Get-Content ".env" | ForEach-Object {
        if ($_ -match "^CLOUDFLARED_TUNNEL_TOKEN=(.*)$") {
            $env:CLOUDFLARED_TUNNEL_TOKEN = $matches[1]
        }
    }
}

if (-not $env:CLOUDFLARED_TUNNEL_TOKEN) {
    Write-Host "Error: CLOUDFLARED_TUNNEL_TOKEN not set in .env file" -ForegroundColor Red
    exit 1
}

cloudflared tunnel run --token $env:CLOUDFLARED_TUNNEL_TOKEN

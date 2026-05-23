Write-Host "--- 1. Extracting data from Terraform ---" -ForegroundColor Cyan
$RG_NAME = terraform output -raw resource_group_name
$PIP_NAME = terraform output -raw public_ip_name

if ([string]::IsNullOrWhiteSpace($RG_NAME) -or $RG_NAME -match "Warning") { 
    Write-Error "Terraform outputs not ready. Run 'terraform refresh' first."
    exit 
}

Write-Host "--- 2. Fetching Public IP from Azure ---" -ForegroundColor Cyan
$PUBLIC_IP = az network public-ip show --resource-group $RG_NAME --name $PIP_NAME --query ipAddress --output tsv

Write-Host "--- 3. Testing Load Balancer on $PUBLIC_IP ---" -ForegroundColor Cyan
1..5 | ForEach-Object { 
    try {
        $resp = (Invoke-WebRequest -Uri "http://$PUBLIC_IP" -UseBasicParsing -TimeoutSec 5).Content
        if ($resp -match "Instance ID") { 
            $id = ($resp -split "Instance ID: ")[1].Split("<")[0]
            Write-Host "Response from: $id" -ForegroundColor Gray
        }
    } catch { Write-Warning "Request failed" }
}

Write-Host "--- 4. Starting Stress Test (Background Jobs) ---" -ForegroundColor Yellow
Write-Host "Spawning 20 background workers to generate CPU load..." -ForegroundColor White

1..20 | ForEach-Object {
    Start-Job -ScriptBlock { 
        param($ip) 
        1..100 | ForEach-Object { 
            try { Invoke-WebRequest -Uri "http://$ip" -UseBasicParsing } catch {} 
        } 
    } -ArgumentList $PUBLIC_IP
}

Write-Host "Stress test is running in background!" -ForegroundColor Green
Write-Host "Wait 5-10 minutes and check Azure Portal for new instances." -ForegroundColor Cyan

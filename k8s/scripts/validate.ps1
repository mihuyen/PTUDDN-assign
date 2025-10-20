# Script để validate nhanh deployment status

param(
    [string]$Namespace = "k8s-demo"
)

Write-Host "🔍 QUICK VALIDATION CHECK" -ForegroundColor Cyan
Write-Host "========================" -ForegroundColor Cyan
Write-Host ""

# Function để check status
function Get-StatusIcon {
    param($condition)
    if ($condition) { return "✅" } else { return "❌" }
}

# 1. Check namespace
$nsExists = kubectl get namespace $Namespace 2>$null
$nsIcon = Get-StatusIcon($nsExists)
Write-Host "$nsIcon Namespace: $Namespace" -ForegroundColor $(if($nsExists){"Green"}else{"Red"})

# 2. Check deployment
$deployment = kubectl get deployment k8s-demo-app -n $Namespace --no-headers 2>$null
$depIcon = Get-StatusIcon($deployment)
Write-Host "$depIcon Deployment: k8s-demo-app" -ForegroundColor $(if($deployment){"Green"}else{"Red"})

if ($deployment) {
    $ready = ($deployment -split '\s+')[1]
    Write-Host "   Ready: $ready" -ForegroundColor Gray
}

# 3. Check pods
$pods = kubectl get pods -n $Namespace --no-headers 2>$null
if ($pods) {
    $runningPods = $pods | Where-Object { $_ -match "Running.*1/1" }
    $totalPods = ($pods | Measure-Object).Count
    $runningCount = ($runningPods | Measure-Object).Count
    
    $podsIcon = Get-StatusIcon($runningCount -gt 0)
    Write-Host "$podsIcon Pods: $runningCount/$totalPods running" -ForegroundColor $(if($runningCount -gt 0){"Green"}else{"Red"})
    
    if ($runningCount -lt $totalPods) {
        Write-Host "   Problem pods:" -ForegroundColor Yellow
        $problemPods = $pods | Where-Object { $_ -notmatch "Running.*1/1" }
        foreach ($pod in $problemPods) {
            $podInfo = $pod -split '\s+'
            Write-Host "   - $($podInfo[0]): $($podInfo[2])" -ForegroundColor Red
        }
    }
} else {
    Write-Host "❌ Pods: None found" -ForegroundColor Red
}

# 4. Check services
$service = kubectl get svc k8s-demo-service -n $Namespace --no-headers 2>$null
$svcIcon = Get-StatusIcon($service)
Write-Host "$svcIcon Service: k8s-demo-service" -ForegroundColor $(if($service){"Green"}else{"Red"})

# 5. Check HPA
$hpa = kubectl get hpa k8s-demo-hpa -n $Namespace --no-headers 2>$null
$hpaIcon = Get-StatusIcon($hpa)
Write-Host "$hpaIcon HPA: k8s-demo-hpa" -ForegroundColor $(if($hpa){"Green"}else{"Red"})

if ($hpa) {
    $targets = ($hpa -split '\s+')[3]
    Write-Host "   Targets: $targets" -ForegroundColor Gray
}

# 6. Check application connectivity
Write-Host ""
Write-Host "🌐 Testing connectivity..." -ForegroundColor Cyan

try {
    $response = Invoke-WebRequest "http://localhost:30080/api/health" -UseBasicParsing -TimeoutSec 5
    if ($response.StatusCode -eq 200) {
        Write-Host "✅ Application: Responding (http://localhost:30080)" -ForegroundColor Green
    }
} catch {
    Write-Host "❌ Application: Not responding (http://localhost:30080)" -ForegroundColor Red
}

try {
    $response = Invoke-WebRequest "http://localhost:30090" -UseBasicParsing -TimeoutSec 5
    if ($response.StatusCode -eq 200) {
        Write-Host "✅ Prometheus: Responding (http://localhost:30090)" -ForegroundColor Green
    }
} catch {
    Write-Host "❌ Prometheus: Not responding (http://localhost:30090)" -ForegroundColor Red
}

try {
    $response = Invoke-WebRequest "http://localhost:30030" -UseBasicParsing -TimeoutSec 5
    if ($response.StatusCode -eq 200) {
        Write-Host "✅ Grafana: Responding (http://localhost:30030)" -ForegroundColor Green
    }
} catch {
    Write-Host "❌ Grafana: Not responding (http://localhost:30030)" -ForegroundColor Red
}

Write-Host ""
Write-Host "📊 SUMMARY" -ForegroundColor Yellow
Write-Host "=========" -ForegroundColor Yellow

$allGood = $nsExists -and $deployment -and $runningCount -gt 0 -and $service

if ($allGood) {
    Write-Host "🎉 All systems are GO! Deployment is healthy!" -ForegroundColor Green
    Write-Host ""
    Write-Host "Next steps:" -ForegroundColor Cyan
    Write-Host "  - Visit: http://localhost:30080" -ForegroundColor White
    Write-Host "  - Run load test: .\scripts\run-load-test.ps1" -ForegroundColor White
    Write-Host "  - Monitor: .\scripts\monitor.ps1" -ForegroundColor White
} else {
    Write-Host "⚠️ Issues detected! Run troubleshooting:" -ForegroundColor Red
    Write-Host "  .\scripts\troubleshoot.ps1" -ForegroundColor White
    
    if (-not $deployment) {
        Write-Host ""
        Write-Host "Quick fix - Redeploy:" -ForegroundColor Yellow
        Write-Host "  .\scripts\undeploy.ps1" -ForegroundColor White
        Write-Host "  .\scripts\deploy.ps1" -ForegroundColor White
    }
}
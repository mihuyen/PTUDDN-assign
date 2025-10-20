# Script để troubleshoot khi pods không chạy được

param(
    [string]$Namespace = "k8s-demo"
)

Write-Host "🔍 KUBERNETES TROUBLESHOOTING SCRIPT" -ForegroundColor Yellow
Write-Host "====================================" -ForegroundColor Yellow
Write-Host ""

# 1. Kiểm tra namespace
Write-Host "1️⃣ Checking namespace..." -ForegroundColor Cyan
$nsExists = kubectl get namespace $Namespace 2>$null
if ($nsExists) {
    Write-Host "✅ Namespace '$Namespace' exists" -ForegroundColor Green
} else {
    Write-Host "❌ Namespace '$Namespace' not found!" -ForegroundColor Red
    Write-Host "Creating namespace..." -ForegroundColor Yellow
    kubectl create namespace $Namespace
}
Write-Host ""

# 2. Kiểm tra pods
Write-Host "2️⃣ Checking pods status..." -ForegroundColor Cyan
$pods = kubectl get pods -n $Namespace --no-headers 2>$null
if ($pods) {
    kubectl get pods -n $Namespace -o wide
    Write-Host ""
    
    # Kiểm tra pods không healthy
    $problemPods = kubectl get pods -n $Namespace --no-headers | Where-Object { $_ -notmatch "Running.*1/1" -and $_ -notmatch "Completed" }
    
    if ($problemPods) {
        Write-Host "🚨 Found problematic pods:" -ForegroundColor Red
        
        foreach ($podLine in $problemPods) {
            $podName = ($podLine -split '\s+')[0]
            $status = ($podLine -split '\s+')[2]
            
            Write-Host ""
            Write-Host "📋 Describing pod: $podName (Status: $status)" -ForegroundColor Yellow
            kubectl describe pod $podName -n $Namespace
            
            Write-Host ""
            Write-Host "📜 Logs for pod: $podName" -ForegroundColor Yellow
            kubectl logs $podName -n $Namespace --tail=20 2>$null
            if ($LASTEXITCODE -ne 0) {
                Write-Host "No logs available for $podName" -ForegroundColor Gray
            }
            
            # Nếu pod crash, xem logs previous
            if ($status -match "CrashLoopBackOff|Error") {
                Write-Host "📜 Previous logs for crashed pod: $podName" -ForegroundColor Yellow
                kubectl logs $podName -n $Namespace --previous --tail=20 2>$null
            }
            Write-Host "----------------------------------------" -ForegroundColor Gray
        }
    } else {
        Write-Host "✅ All pods are running healthy!" -ForegroundColor Green
    }
} else {
    Write-Host "❌ No pods found in namespace $Namespace" -ForegroundColor Red
}
Write-Host ""

# 3. Kiểm tra services
Write-Host "3️⃣ Checking services..." -ForegroundColor Cyan
kubectl get svc -n $Namespace
Write-Host ""

# 4. Kiểm tra deployments
Write-Host "4️⃣ Checking deployments..." -ForegroundColor Cyan
kubectl get deployment -n $Namespace
Write-Host ""

# 5. Kiểm tra events
Write-Host "5️⃣ Recent events in namespace..." -ForegroundColor Cyan
kubectl get events -n $Namespace --sort-by='.lastTimestamp' | Select-Object -Last 10
Write-Host ""

# 6. Kiểm tra HPA
Write-Host "6️⃣ Checking HPA..." -ForegroundColor Cyan
$hpa = kubectl get hpa -n $Namespace --no-headers 2>$null
if ($hpa) {
    kubectl get hpa -n $Namespace
    
    # Kiểm tra metrics server
    Write-Host ""
    Write-Host "📊 Checking metrics server..." -ForegroundColor Yellow
    $metricsAvailable = kubectl top nodes 2>$null
    if ($metricsAvailable) {
        Write-Host "✅ Metrics server is working" -ForegroundColor Green
        kubectl top pods -n $Namespace 2>$null
    } else {
        Write-Host "❌ Metrics server not available!" -ForegroundColor Red
        Write-Host "Install with: kubectl apply -f https://github.com/kubernetes-sigs/metrics-server/releases/latest/download/components.yaml" -ForegroundColor Yellow
    }
} else {
    Write-Host "No HPA found in namespace $Namespace" -ForegroundColor Gray
}
Write-Host ""

# 7. Kiểm tra Docker images
Write-Host "7️⃣ Checking Docker images..." -ForegroundColor Cyan
$images = docker images | findstr "k8s-demo-app"
if ($images) {
    Write-Host "✅ Docker images found:" -ForegroundColor Green
    $images
} else {
    Write-Host "❌ k8s-demo-app Docker image not found!" -ForegroundColor Red
    Write-Host "Build with: docker build -t k8s-demo-app:1.0.0 ." -ForegroundColor Yellow
}
Write-Host ""

# 8. Network connectivity test
Write-Host "8️⃣ Testing network connectivity..." -ForegroundColor Cyan
$runningPods = kubectl get pods -n $Namespace --no-headers | Where-Object { $_ -match "Running" }
if ($runningPods) {
    $firstPod = ($runningPods[0] -split '\s+')[0]
    Write-Host "Testing connectivity to pod: $firstPod" -ForegroundColor Yellow
    
    # Port forward test
    Write-Host "Starting port-forward test..." -ForegroundColor Gray
    $job = Start-Job -ScriptBlock {
        param($pod, $ns)
        kubectl port-forward $pod -n $ns 8080:8080 2>$null
    } -ArgumentList $firstPod, $Namespace
    
    Start-Sleep -Seconds 3
    
    try {
        $response = Invoke-WebRequest "http://localhost:8080/api/health" -UseBasicParsing -TimeoutSec 5 2>$null
        if ($response.StatusCode -eq 200) {
            Write-Host "✅ Application is responding on port 8080" -ForegroundColor Green
        }
    } catch {
        Write-Host "❌ Application not responding on port 8080" -ForegroundColor Red
    }
    
    Stop-Job $job -Force 2>$null
    Remove-Job $job -Force 2>$null
} else {
    Write-Host "No running pods to test" -ForegroundColor Gray
}
Write-Host ""

# 9. Quick fixes suggestions
Write-Host "🛠️  QUICK FIXES SUGGESTIONS" -ForegroundColor Yellow
Write-Host "=========================" -ForegroundColor Yellow
Write-Host ""
Write-Host "If pods are in ImagePullBackOff:" -ForegroundColor Cyan
Write-Host "  docker build -t k8s-demo-app:1.0.0 ." -ForegroundColor White
Write-Host "  kubectl patch deployment k8s-demo-app -n $Namespace -p '{\"spec\":{\"template\":{\"spec\":{\"containers\":[{\"name\":\"k8s-demo-app\",\"imagePullPolicy\":\"IfNotPresent\"}]}}}}'" -ForegroundColor White
Write-Host ""
Write-Host "If pods are Pending:" -ForegroundColor Cyan
Write-Host "  kubectl patch deployment k8s-demo-app -n $Namespace -p '{\"spec\":{\"template\":{\"spec\":{\"containers\":[{\"name\":\"k8s-demo-app\",\"resources\":{\"requests\":{\"memory\":\"128Mi\",\"cpu\":\"100m\"}}}]}}}}'" -ForegroundColor White
Write-Host ""
Write-Host "If metrics server missing:" -ForegroundColor Cyan
Write-Host "  kubectl apply -f https://github.com/kubernetes-sigs/metrics-server/releases/latest/download/components.yaml" -ForegroundColor White
Write-Host ""
Write-Host "To restart deployment:" -ForegroundColor Cyan
Write-Host "  kubectl rollout restart deployment/k8s-demo-app -n $Namespace" -ForegroundColor White
Write-Host ""
Write-Host "To delete and redeploy:" -ForegroundColor Cyan
Write-Host "  .\scripts\undeploy.ps1" -ForegroundColor White
Write-Host "  .\scripts\deploy.ps1" -ForegroundColor White
Write-Host ""

Write-Host "✅ Troubleshooting completed!" -ForegroundColor Green
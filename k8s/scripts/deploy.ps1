# Deploy ứng dụng lên Kubernetes

Write-Host "Deploying to Kubernetes..." -ForegroundColor Green

# Kiểm tra prerequisites
Write-Host "Checking prerequisites..." -ForegroundColor Yellow

# Kiểm tra kubectl
$kubectl = Get-Command kubectl -ErrorAction SilentlyContinue
if (-not $kubectl) {
    Write-Host "ERROR: kubectl not found!" -ForegroundColor Red
    exit 1
}

# Kiểm tra Docker image
$image = docker images k8s-demo-app:1.0.0 --format "table {{.Repository}}:{{.Tag}}" | Select-String "k8s-demo-app:1.0.0"
if (-not $image) {
    Write-Host "WARNING: Docker image k8s-demo-app:1.0.0 not found!" -ForegroundColor Yellow
    Write-Host "Building image first..." -ForegroundColor Yellow
    docker build -t k8s-demo-app:1.0.0 .
    if ($LASTEXITCODE -ne 0) {
        Write-Host "ERROR: Failed to build Docker image!" -ForegroundColor Red
        exit 1
    }
}

# Tạo namespace
Write-Host "Creating namespace..." -ForegroundColor Yellow
kubectl apply -f k8s/namespace.yaml

# Deploy ứng dụng
Write-Host "Deploying application..." -ForegroundColor Yellow
kubectl apply -f k8s/deployment.yaml
kubectl apply -f k8s/service.yaml

# Đợi deployment ready
Write-Host "Waiting for deployment to be ready..." -ForegroundColor Yellow
kubectl wait --for=condition=progressing deployment/k8s-demo-app -n k8s-demo --timeout=60s

# Deploy HPA
Write-Host "Deploying Horizontal Pod Autoscaler..." -ForegroundColor Yellow
kubectl apply -f k8s/hpa.yaml

# Deploy Prometheus
Write-Host "Deploying Prometheus..." -ForegroundColor Yellow
kubectl apply -f k8s/prometheus-config.yaml
kubectl apply -f k8s/prometheus-deployment.yaml

# Deploy Grafana
Write-Host "Deploying Grafana..." -ForegroundColor Yellow
kubectl apply -f k8s/grafana-deployment.yaml

Write-Host ""
Write-Host "Deployment completed!" -ForegroundColor Green
Write-Host ""

# Validation steps
Write-Host "Validating deployment..." -ForegroundColor Yellow

# Đợi pods ready với timeout
Write-Host "Waiting for application pods to be ready (timeout: 5 minutes)..." -ForegroundColor Yellow
$waitResult = kubectl wait --for=condition=ready pod -l app=k8s-demo-app -n k8s-demo --timeout=300s 2>&1

if ($LASTEXITCODE -eq 0) {
    Write-Host "✅ Application pods are ready!" -ForegroundColor Green
} else {
    Write-Host "❌ Pods failed to start within timeout!" -ForegroundColor Red
    Write-Host "Running troubleshooting..." -ForegroundColor Yellow
    .\scripts\troubleshoot.ps1
    exit 1
}

# Kiểm tra services
Write-Host "Checking services..." -ForegroundColor Yellow
$services = kubectl get svc -n k8s-demo --no-headers
if ($services) {
    Write-Host "✅ Services are created!" -ForegroundColor Green
} else {
    Write-Host "❌ No services found!" -ForegroundColor Red
}

# Kiểm tra HPA
Write-Host "Checking HPA..." -ForegroundColor Yellow
Start-Sleep -Seconds 10  # Đợi HPA initialize
$hpa = kubectl get hpa -n k8s-demo --no-headers 2>$null
if ($hpa) {
    Write-Host "✅ HPA is created!" -ForegroundColor Green
} else {
    Write-Host "⚠️ HPA not ready yet (may need metrics server)" -ForegroundColor Yellow
}

Write-Host ""
Write-Host "=== DEPLOYMENT SUMMARY ===" -ForegroundColor Cyan
Write-Host ""

# Show status
kubectl get all -n k8s-demo

Write-Host ""
Write-Host "=== ACCESS INFORMATION ===" -ForegroundColor Cyan
Write-Host ""
Write-Host "Application URL: http://localhost:30080" -ForegroundColor Green
Write-Host "Prometheus URL: http://localhost:30090" -ForegroundColor Green
Write-Host "Grafana URL: http://localhost:30030 (admin/admin123)" -ForegroundColor Green
Write-Host ""

# Test connectivity
Write-Host "Testing application connectivity..." -ForegroundColor Yellow
try {
    $response = Invoke-WebRequest "http://localhost:30080/api/health" -UseBasicParsing -TimeoutSec 10
    if ($response.StatusCode -eq 200) {
        Write-Host "✅ Application is responding!" -ForegroundColor Green
        Write-Host "Response: $($response.Content)" -ForegroundColor Gray
    }
} catch {
    Write-Host "⚠️ Application not responding yet (may still be starting)" -ForegroundColor Yellow
    Write-Host "You can check status with: .\scripts\monitor.ps1" -ForegroundColor White
}

Write-Host ""
Write-Host "=== USEFUL COMMANDS ===" -ForegroundColor Yellow
Write-Host ""
Write-Host "Monitor deployment:" -ForegroundColor White
Write-Host "  .\scripts\monitor.ps1" -ForegroundColor Gray
Write-Host ""
Write-Host "Check pod logs:" -ForegroundColor White
Write-Host "  kubectl logs -f -l app=k8s-demo-app -n k8s-demo" -ForegroundColor Gray
Write-Host ""
Write-Host "Run load test:" -ForegroundColor White
Write-Host "  .\scripts\run-load-test.ps1" -ForegroundColor Gray
Write-Host ""
Write-Host "Troubleshoot issues:" -ForegroundColor White
Write-Host "  .\scripts\troubleshoot.ps1" -ForegroundColor Gray

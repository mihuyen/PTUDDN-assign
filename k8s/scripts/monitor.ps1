# Monitor Kubernetes resources

param(
    [int]$Interval = 5
)

Write-Host "Monitoring Kubernetes resources (Ctrl+C to stop)..." -ForegroundColor Green
Write-Host ""

while ($true) {
    Clear-Host
    
    Write-Host "=== PODS STATUS ===" -ForegroundColor Cyan
    kubectl get pods -n k8s-demo -o wide
    
    Write-Host ""
    Write-Host "=== HPA STATUS ===" -ForegroundColor Cyan
    kubectl get hpa -n k8s-demo
    
    Write-Host ""
    Write-Host "=== SERVICES ===" -ForegroundColor Cyan
    kubectl get svc -n k8s-demo
    
    Write-Host ""
    Write-Host "=== RESOURCE USAGE (Top Pods) ===" -ForegroundColor Cyan
    kubectl top pods -n k8s-demo 2>$null
    
    Write-Host ""
    Write-Host "Press Ctrl+C to stop monitoring..." -ForegroundColor Yellow
    Write-Host "Refreshing in $Interval seconds..." -ForegroundColor Gray
    
    Start-Sleep -Seconds $Interval
}

# ArgoCD Installation and Setup Script for Windows
# Run this script in PowerShell with administrative privileges

Write-Host "🚀 Installing ArgoCD..." -ForegroundColor Green

# Create ArgoCD namespace
Write-Host "📁 Creating ArgoCD namespace..." -ForegroundColor Yellow
kubectl create namespace argocd --dry-run=client -o yaml | kubectl apply -f -

# Install ArgoCD
Write-Host "📦 Installing ArgoCD components..." -ForegroundColor Yellow
kubectl apply -n argocd -f https://raw.githubusercontent.com/argoproj/argo-cd/stable/manifests/install.yaml

# Wait for ArgoCD to be ready
Write-Host "⏳ Waiting for ArgoCD to be ready..." -ForegroundColor Yellow
kubectl wait --for=condition=available --timeout=600s deployment/argocd-server -n argocd
kubectl wait --for=condition=available --timeout=600s deployment/argocd-application-controller -n argocd
kubectl wait --for=condition=available --timeout=600s deployment/argocd-dex-server -n argocd

# Get initial admin password
Write-Host "🔑 Getting initial admin password..." -ForegroundColor Yellow
$argoCdPassword = kubectl -n argocd get secret argocd-initial-admin-secret -o jsonpath="{.data.password}"
$decodedPassword = [System.Text.Encoding]::UTF8.GetString([System.Convert]::FromBase64String($argoCdPassword))

Write-Host "✅ ArgoCD installation completed!" -ForegroundColor Green
Write-Host ""
Write-Host "📋 Access Information:" -ForegroundColor Cyan
Write-Host "🌐 ArgoCD UI: http://localhost:8080" -ForegroundColor White
Write-Host "👤 Username: admin" -ForegroundColor White
Write-Host "🔐 Password: $decodedPassword" -ForegroundColor White
Write-Host ""
Write-Host "🚀 To access ArgoCD UI, run:" -ForegroundColor Cyan
Write-Host "kubectl port-forward svc/argocd-server -n argocd 8080:443" -ForegroundColor White
Write-Host ""
Write-Host "📚 Next steps:" -ForegroundColor Cyan
Write-Host "1. Access ArgoCD UI" -ForegroundColor White
Write-Host "2. Change admin password" -ForegroundColor White
Write-Host "3. Install ArgoCD applications: kubectl apply -f argocd/applications/" -ForegroundColor White
Write-Host "4. Configure repositories and sync policies" -ForegroundColor White

# Optionally patch ArgoCD server for insecure mode (development only)
Write-Host ""
$enableInsecure = Read-Host "🔒 Enable insecure mode for development? (y/N)"
if ($enableInsecure -eq "y" -or $enableInsecure -eq "Y") {
    Write-Host "⚠️  Enabling insecure mode (not recommended for production)..." -ForegroundColor Yellow
    kubectl patch deployment argocd-server -n argocd --patch='{"spec":{"template":{"spec":{"containers":[{"name":"argocd-server","args":["argocd-server","--insecure"]}]}}}}'
    kubectl rollout status deployment/argocd-server -n argocd
    Write-Host "✅ Insecure mode enabled. You can now access ArgoCD at http://localhost:8080" -ForegroundColor Green
}

Write-Host ""
Write-Host "🎉 ArgoCD setup completed successfully!" -ForegroundColor Green
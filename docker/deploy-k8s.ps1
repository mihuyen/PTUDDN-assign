# PowerShell script to deploy to Kubernetes

Write-Host "Deploying application to Kubernetes..." -ForegroundColor Green

# Apply ConfigMap
Write-Host "Creating ConfigMap..." -ForegroundColor Yellow
kubectl apply -f k8s/app-configmap.yaml

# Apply MySQL PV and PVC
Write-Host "Creating MySQL Persistent Volume..." -ForegroundColor Yellow
kubectl apply -f k8s/mysql-pv.yaml

# Apply MySQL Deployment
Write-Host "Deploying MySQL..." -ForegroundColor Yellow
kubectl apply -f k8s/mysql-deployment.yaml

# Wait for MySQL to be ready
Write-Host "Waiting for MySQL to be ready..." -ForegroundColor Yellow
kubectl wait --for=condition=ready pod -l app=mysql --timeout=300s

# Apply SpringBoot App Deployment
Write-Host "Deploying SpringBoot Application..." -ForegroundColor Yellow
kubectl apply -f k8s/app-deployment.yaml

# Wait for app to be ready
Write-Host "Waiting for SpringBoot App to be ready..." -ForegroundColor Yellow
kubectl wait --for=condition=ready pod -l app=springboot-app --timeout=300s

# Show status
Write-Host "Deployment completed!" -ForegroundColor Green
Write-Host "Getting pods status:" -ForegroundColor Cyan
kubectl get pods

Write-Host "Getting services:" -ForegroundColor Cyan
kubectl get services

Write-Host "Application URL: http://localhost:30080" -ForegroundColor Magenta
Write-Host "Health check: http://localhost:30080/actuator/health" -ForegroundColor Magenta
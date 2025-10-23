# Clean up Kubernetes deployment

Write-Host "Cleaning up Kubernetes deployment..." -ForegroundColor Red

kubectl delete -f k8s/app-deployment.yaml
kubectl delete -f k8s/mysql-deployment.yaml  
kubectl delete -f k8s/mysql-pv.yaml
kubectl delete -f k8s/app-configmap.yaml

Write-Host "Cleanup completed!" -ForegroundColor Green
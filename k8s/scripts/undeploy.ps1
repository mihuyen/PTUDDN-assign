# Xóa tất cả resources trong namespace k8s-demo

Write-Host "Undeploying from Kubernetes..." -ForegroundColor Red

kubectl delete -f k8s/hpa.yaml
kubectl delete -f k8s/service.yaml
kubectl delete -f k8s/deployment.yaml
kubectl delete -f k8s/grafana-deployment.yaml
kubectl delete -f k8s/prometheus-deployment.yaml
kubectl delete -f k8s/prometheus-config.yaml
kubectl delete -f k8s/namespace.yaml

Write-Host "Undeployment completed!" -ForegroundColor Green

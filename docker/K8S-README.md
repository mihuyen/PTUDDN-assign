# Kubernetes Deployment Guide

## Yêu cầu
- Docker Desktop với Kubernetes enabled
- kubectl command line tool

## Cách bật Kubernetes trong Docker Desktop
1. Mở Docker Desktop
2. Vào Settings (⚙️) → Kubernetes
3. Tick vào "Enable Kubernetes"
4. Click "Apply & Restart"
5. Chờ vài phút để Kubernetes khởi động

## Deploy ứng dụng

### Cách 1: Sử dụng PowerShell script
```powershell
.\deploy-k8s.ps1
```

### Cách 2: Deploy từng bước
```bash
# 1. Deploy ConfigMap
kubectl apply -f k8s/app-configmap.yaml

# 2. Deploy MySQL Persistent Volume
kubectl apply -f k8s/mysql-pv.yaml

# 3. Deploy MySQL
kubectl apply -f k8s/mysql-deployment.yaml

# 4. Deploy SpringBoot App
kubectl apply -f k8s/app-deployment.yaml
```

## Kiểm tra deployment

```bash
# Xem pods
kubectl get pods

# Xem services
kubectl get services

# Xem logs của app
kubectl logs -l app=springboot-app

# Xem logs của MySQL
kubectl logs -l app=mysql
```

## Truy cập ứng dụng
- URL: http://localhost:30080
- Health check: http://localhost:30080/actuator/health

## Xóa deployment
```bash
kubectl delete -f k8s/
```

## Troubleshooting

### MySQL không khởi động
```bash
kubectl describe pod -l app=mysql
kubectl logs -l app=mysql
```

### App không kết nối được MySQL
```bash
kubectl logs -l app=springboot-app
kubectl exec -it <pod-name> -- ping mysql
```

### Port không accessible
```bash
kubectl get services
kubectl port-forward service/springboot-app-service 8080:8080
```
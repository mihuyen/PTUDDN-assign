# Quick Start Guide

## Bắt đầu nhanh (Quick Start)

### 1. Build ứng dụng
```powershell
mvn clean package -DskipTests
```

### 2. Build Docker image
```powershell
.\scripts\build-image.ps1
```

### 3. Deploy lên K8s
```powershell
.\scripts\deploy.ps1
```

### 4. Validate deployment
```powershell
# Kiểm tra nhanh status
.\scripts\validate.ps1

# Hoặc troubleshoot chi tiết
.\scripts\troubleshoot.ps1
```

### 5. Truy cập ứng dụng (nếu deployment thành công)
- Application: http://localhost:30080
- Prometheus: http://localhost:30090
- Grafana: http://localhost:30030 (admin/admin123)

### 6. Test autoscaling
```powershell
# Terminal 1: Monitor
.\scripts\monitor.ps1

# Terminal 2: Run load test
.\scripts\run-load-test.ps1
```

### 7. Dọn dẹp
```powershell
.\scripts\undeploy.ps1
```

## 🚨 Nếu pods không chạy được

### Cách 1: Sử dụng script troubleshoot
```powershell
.\scripts\troubleshoot.ps1
```

### Cách 2: Manual troubleshooting
```powershell
# Kiểm tra pods
kubectl get pods -n k8s-demo

# Xem lỗi chi tiết
kubectl describe pods -n k8s-demo

# Xem logs
kubectl logs -l app=k8s-demo-app -n k8s-demo

# Xem events
kubectl get events -n k8s-demo --sort-by='.lastTimestamp'
```

### Lỗi thường gặp và cách sửa:

**1. ImagePullBackOff:**
```powershell
# Build lại image
docker build -t k8s-demo-app:1.0.0 .

# Patch deployment để dùng local image
kubectl patch deployment k8s-demo-app -n k8s-demo -p '{"spec":{"template":{"spec":{"containers":[{"name":"k8s-demo-app","imagePullPolicy":"IfNotPresent"}]}}}}'
```

**2. CrashLoopBackOff:**
```powershell
# Xem logs previous container
kubectl logs -l app=k8s-demo-app -n k8s-demo --previous

# Giảm resource requirements
kubectl patch deployment k8s-demo-app -n k8s-demo -p '{"spec":{"template":{"spec":{"containers":[{"name":"k8s-demo-app","resources":{"requests":{"memory":"128Mi","cpu":"100m"}}}]}}}}'
```

**3. Pending Pods:**
```powershell
# Kiểm tra resources
kubectl top nodes

# Giảm resource requests
kubectl patch deployment k8s-demo-app -n k8s-demo -p '{"spec":{"template":{"spec":{"containers":[{"name":"k8s-demo-app","resources":{"requests":{"memory":"128Mi","cpu":"100m"}}}]}}}}'
```

**4. HPA không hoạt động:**
```powershell
# Cài metrics server
kubectl apply -f https://github.com/kubernetes-sigs/metrics-server/releases/latest/download/components.yaml

# Đợi và kiểm tra
kubectl wait --for=condition=ready pod -l k8s-app=metrics-server -n kube-system --timeout=60s
kubectl top nodes
```

## Các lệnh kubectl hữu ích

```powershell
# Xem pods
kubectl get pods -n k8s-demo

# Xem HPA
kubectl get hpa -n k8s-demo

# Xem logs
kubectl logs -f -l app=k8s-demo-app -n k8s-demo

# Describe HPA
kubectl describe hpa k8s-demo-hpa -n k8s-demo

# Top pods (resource usage)
kubectl top pods -n k8s-demo

# Port forward
kubectl port-forward svc/k8s-demo-service -n k8s-demo 8080:80
```

## Test endpoints manually

```powershell
# Health check
Invoke-WebRequest http://localhost:30080/api/health

# Info
Invoke-WebRequest http://localhost:30080/api/info

# CPU load (tạo load để test autoscaling)
Invoke-WebRequest "http://localhost:30080/api/cpu-load?duration=5000&threads=8"

# Memory load
Invoke-WebRequest "http://localhost:30080/api/memory-load?sizeMB=50"
```

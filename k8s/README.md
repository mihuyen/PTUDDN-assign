# K8s Demo Application - Deployment & Autoscaling

## 📋 Mô tả

Dự án demo triển khai ứng dụng Spring Boot lên Kubernetes với đầy đủ tính năng:
- ☸️ **Kubernetes Deployment** với Service và HPA
- 📈 **Monitoring** với Prometheus và Grafana
- ⚡ **Horizontal Pod Autoscaling** tự động scale theo CPU/Memory
- 🧪 **Load Testing** với JMeter để kiểm tra autoscaling

## 🏗️ Kiến trúc

```
┌─────────────────────────────────────────────────────────────┐
│                        Kubernetes Cluster                    │
│                                                              │
│  ┌──────────────────────────────────────────────────────┐  │
│  │  Namespace: k8s-demo                                  │  │
│  │                                                        │  │
│  │  ┌──────────────┐  ┌──────────────┐  ┌────────────┐ │  │
│  │  │ K8s Demo App │  │ K8s Demo App │  │    ...     │ │  │
│  │  │   (Pod 1)    │  │   (Pod 2)    │  │  (Pod N)   │ │  │
│  │  └──────────────┘  └──────────────┘  └────────────┘ │  │
│  │         ▲                ▲                  ▲         │  │
│  │         └────────────────┴──────────────────┘         │  │
│  │                          │                             │  │
│  │                  ┌───────▼────────┐                   │  │
│  │                  │    Service     │                   │  │
│  │                  │  (LoadBalancer)│                   │  │
│  │                  └────────────────┘                   │  │
│  │                                                        │  │
│  │  ┌──────────────┐  ┌──────────────┐  ┌────────────┐ │  │
│  │  │     HPA      │  │  Prometheus  │  │  Grafana   │ │  │
│  │  │ (Autoscaler) │  │ (Monitoring) │  │ (Dashboard)│ │  │
│  │  └──────────────┘  └──────────────┘  └────────────┘ │  │
│  └──────────────────────────────────────────────────────┘  │
└─────────────────────────────────────────────────────────────┘
```

## 🚀 Yêu cầu

### Phần mềm cần cài đặt:

1. **Java 17+**
   ```powershell
   java -version
   ```

2. **Maven 3.6+**
   ```powershell
   mvn -version
   ```

3. **Docker Desktop**
   ```powershell
   docker --version
   ```

4. **Kubernetes** (Docker Desktop có sẵn hoặc Minikube)
   ```powershell
   kubectl version --client
   ```

5. **Apache JMeter** (cho load testing)
   - Download: https://jmeter.apache.org/download_jmeter.cgi
   - Thêm JMeter vào PATH

### Enable Kubernetes trong Docker Desktop:
1. Mở Docker Desktop
2. Settings → Kubernetes
3. Check "Enable Kubernetes"
4. Apply & Restart

## 📦 Cài đặt và Chạy

### Bước 1: Build ứng dụng

```powershell
# Build với Maven
mvn clean package

# Hoặc skip tests
mvn clean package -DskipTests
```

### Bước 2: Build Docker Image

```powershell
# Chạy script build
.\scripts\build-image.ps1

# Hoặc build manual
docker build -t k8s-demo-app:1.0.0 .
```

### Bước 3: Deploy lên Kubernetes

```powershell
# Deploy toàn bộ hệ thống
.\scripts\deploy.ps1
```

Script sẽ deploy:
- Namespace: `k8s-demo`
- Application Deployment (2 replicas ban đầu)
- Service (NodePort 30080)
- HPA (min: 2, max: 10 pods)
- Prometheus (NodePort 30090)
- Grafana (NodePort 30030)

### Bước 4: Kiểm tra deployment

```powershell
# Kiểm tra tất cả resources
kubectl get all -n k8s-demo

# Xem pods với chi tiết
kubectl get pods -n k8s-demo -o wide

# Xem services
kubectl get svc -n k8s-demo

# Xem HPA status
kubectl get hpa -n k8s-demo
```

#### 🔍 Nếu pods không chạy được (Status: Pending, CrashLoopBackOff, Error):

**1. Kiểm tra describe pod để xem lỗi chi tiết:**
```powershell
# Liệt kê tất cả pods
kubectl get pods -n k8s-demo

# Describe pod cụ thể (thay <pod-name> bằng tên pod thực tế)
kubectl describe pod <pod-name> -n k8s-demo

# Hoặc describe tất cả pods
kubectl describe pods -n k8s-demo
```

**2. Kiểm tra logs:**
```powershell
# Xem logs của pod cụ thể
kubectl logs <pod-name> -n k8s-demo

# Xem logs của tất cả pods với label app=k8s-demo-app
kubectl logs -l app=k8s-demo-app -n k8s-demo

# Xem logs real-time
kubectl logs -f -l app=k8s-demo-app -n k8s-demo
```

**3. Kiểm tra events trong namespace:**
```powershell
kubectl get events -n k8s-demo --sort-by='.lastTimestamp'
```

#### 🚨 Các lỗi thường gặp và cách sửa:

**A. Lỗi ImagePullBackOff / ErrImagePull:**
```
Error: Failed to pull image "k8s-demo-app:1.0.0": rpc error: code = NotFound
```
**Nguyên nhân:** Docker image chưa được build hoặc không tìm thấy

**Giải pháp:**
```powershell
# Build lại Docker image
docker build -t k8s-demo-app:1.0.0 .

# Kiểm tra image đã có chưa
docker images | findstr k8s-demo-app

# Nếu dùng Minikube, load image vào Minikube
minikube image load k8s-demo-app:1.0.0

# Hoặc sửa imagePullPolicy trong deployment
kubectl patch deployment k8s-demo-app -n k8s-demo -p '{"spec":{"template":{"spec":{"containers":[{"name":"k8s-demo-app","imagePullPolicy":"IfNotPresent"}]}}}}'
```

**B. Lỗi CrashLoopBackOff:**
```
Status: CrashLoopBackOff
```
**Nguyên nhân:** Container start rồi crash liên tục

**Giải pháp:**
```powershell
# Xem logs để tìm lỗi
kubectl logs <pod-name> -n k8s-demo --previous

# Kiểm tra health check endpoints
kubectl port-forward <pod-name> -n k8s-demo 8080:8080
# Mở browser: http://localhost:8080/actuator/health
```

**C. Lỗi Pending:**
```
Status: Pending
```
**Nguyên nhân:** Không đủ resources hoặc scheduling issues

**Giải pháp:**
```powershell
# Kiểm tra node resources
kubectl top nodes

# Giảm resource requests trong deployment (tạm thời)
kubectl patch deployment k8s-demo-app -n k8s-demo -p '{"spec":{"template":{"spec":{"containers":[{"name":"k8s-demo-app","resources":{"requests":{"memory":"128Mi","cpu":"100m"}}}]}}}}'
```

**D. Lỗi Metrics Server (cho HPA):**
```
Error: Metrics API not available
```
**Giải pháp:**
```powershell
# Cài đặt metrics server
kubectl apply -f https://github.com/kubernetes-sigs/metrics-server/releases/latest/download/components.yaml

# Đợi metrics server ready
kubectl wait --for=condition=ready pod -l k8s-app=metrics-server -n kube-system --timeout=60s

# Kiểm tra metrics
kubectl top nodes
kubectl top pods -n k8s-demo
```

#### ✅ Verification Steps:

**1. Đợi pods ready:**
```powershell
kubectl wait --for=condition=ready pod -l app=k8s-demo-app -n k8s-demo --timeout=300s
```

**2. Test application:**
```powershell
# Port forward để test local
kubectl port-forward svc/k8s-demo-service -n k8s-demo 8080:80

# Test trong terminal khác
Invoke-WebRequest http://localhost:8080/api/health -UseBasicParsing
```

**3. Kiểm tra tất cả services:**
```powershell
Write-Host "=== DEPLOYMENT STATUS ===" -ForegroundColor Cyan
kubectl get deployment -n k8s-demo

Write-Host "=== PODS STATUS ===" -ForegroundColor Cyan  
kubectl get pods -n k8s-demo

Write-Host "=== SERVICES ===" -ForegroundColor Cyan
kubectl get svc -n k8s-demo

Write-Host "=== HPA STATUS ===" -ForegroundColor Cyan
kubectl get hpa -n k8s-demo
```

**4. Nếu tất cả OK, test qua NodePort:**
- Application: http://localhost:30080
- Prometheus: http://localhost:30090  
- Grafana: http://localhost:30030

## 🌐 Truy cập ứng dụng

Sau khi deploy thành công:

| Service | URL | Credentials |
|---------|-----|-------------|
| **Application** | http://localhost:30080 | - |
| **Prometheus** | http://localhost:30090 | - |
| **Grafana** | http://localhost:30030 | admin / admin123 |

### API Endpoints:

- `GET /` - Trang chủ với UI
- `GET /api/health` - Health check
- `GET /api/info` - Application info
- `GET /api/ping` - Simple ping
- `GET /api/cpu-load?duration=1000&threads=4` - Tạo CPU load
- `GET /api/memory-load?sizeMB=50` - Tạo memory load
- `GET /actuator/health` - Actuator health
- `GET /actuator/prometheus` - Prometheus metrics

## 📊 Monitoring

### 1. Real-time Monitoring với Script

```powershell
# Monitor pods và HPA real-time (refresh mỗi 5 giây)
.\scripts\monitor.ps1

# Hoặc custom interval
.\scripts\monitor.ps1 -Interval 10
```

### 2. Prometheus

Truy cập: http://localhost:30090

Queries hữu ích:
```promql
# CPU usage
rate(process_cpu_usage[1m])

# Memory usage
jvm_memory_used_bytes / jvm_memory_max_bytes

# HTTP requests rate
rate(http_server_requests_seconds_count[1m])

# Response time
rate(http_server_requests_seconds_sum[1m]) / rate(http_server_requests_seconds_count[1m])
```

### 3. Grafana Dashboard

1. Truy cập: http://localhost:30030
2. Login: admin / admin123
3. Add Data Source:
   - Type: Prometheus
   - URL: http://prometheus:9090
   - Save & Test
4. Import Dashboard:
   - Dashboard ID: 12900 (Spring Boot 2.x Statistics)
   - Hoặc tạo custom dashboard

## ⚡ Kiểm tra Autoscaling

### Manual Testing

#### 1. Kiểm tra trạng thái ban đầu:
```powershell
kubectl get hpa -n k8s-demo
```

Output mẫu:
```
NAME            REFERENCE                 TARGETS         MINPODS   MAXPODS   REPLICAS
k8s-demo-hpa    Deployment/k8s-demo-app   5%/50%, 20%/70%   2         10        2
```

#### 2. Tạo load để trigger scaling:

**Cách 1: Dùng curl/Invoke-WebRequest:**
```powershell
# Tạo nhiều requests liên tục
1..100 | ForEach-Object {
    Invoke-WebRequest -Uri "http://localhost:30080/api/cpu-load?duration=2000&threads=4" -UseBasicParsing
    Start-Sleep -Milliseconds 100
}
```

**Cách 2: Dùng browser:**
Mở nhiều tab và truy cập:
```
http://localhost:30080/api/cpu-load?duration=5000&threads=8
```

#### 3. Monitor quá trình scaling:
```powershell
# Terminal 1: Monitor HPA
kubectl get hpa -n k8s-demo --watch

# Terminal 2: Monitor Pods
kubectl get pods -n k8s-demo --watch

# Terminal 3: Monitor resource usage
kubectl top pods -n k8s-demo --watch
```

### Automated Testing với JMeter

#### 1. Chạy load test:
```powershell
.\scripts\run-load-test.ps1
```

Hoặc với custom target:
```powershell
.\scripts\run-load-test.ps1 -Host "192.168.1.100" -Port "30080"
```

#### 2. Kịch bản test:

Test gồm 3 phases:
- **Phase 1 - Warm-up**: 10 users, 5 loops (15s)
- **Phase 2 - Load Increase**: 50 users, ramp-up 60s, duration 5 phút
- **Phase 3 - Peak Load**: 100 users, ramp-up 30s, duration 3 phút

#### 3. Xem kết quả:

JMeter sẽ tự động:
- Tạo file `.jtl` với raw results
- Generate HTML report
- Mở report trong browser

Report bao gồm:
- Response times
- Throughput
- Error rate
- Percentiles (90th, 95th, 99th)

### Monitoring Autoscaling

Trong khi test, quan sát:

1. **HPA Metrics:**
```powershell
kubectl describe hpa k8s-demo-hpa -n k8s-demo
```

2. **Pod Count Changes:**
```powershell
kubectl get pods -n k8s-demo -l app=k8s-demo-app
```

3. **Events:**
```powershell
kubectl get events -n k8s-demo --sort-by='.lastTimestamp'
```

4. **Prometheus Metrics:**
- CPU: `container_cpu_usage_seconds_total`
- Memory: `container_memory_usage_bytes`
- Pods: `kube_deployment_status_replicas`

### Kết quả mong đợi:

1. **Scale Up:**
   - Khi CPU > 50% hoặc Memory > 70%
   - HPA tăng số pods (max 10)
   - Pods mới được tạo và chạy

2. **Scale Down:**
   - Sau khi load giảm
   - Chờ stabilization window (5 phút)
   - HPA giảm số pods về min (2)

## 🧹 Dọn dẹp

### Xóa toàn bộ deployment:
```powershell
.\scripts\undeploy.ps1
```

### Xóa Docker images:
```powershell
docker rmi k8s-demo-app:1.0.0
```

## 📁 Cấu trúc Project

```
k8s/
├── src/                          # Source code
│   ├── main/
│   │   ├── java/
│   │   │   └── com/example/
│   │   │       ├── Main.java                    # Main application
│   │   │       └── controller/
│   │   │           ├── HealthController.java    # Health endpoints
│   │   │           ├── HomeController.java      # Home page
│   │   │           └── LoadController.java      # Load generation endpoints
│   │   └── resources/
│   │       ├── application.yml                  # Application config
│   │       └── templates/
│   │           └── index.html                   # Home page template
│   └── test/
├── k8s/                          # Kubernetes manifests
│   ├── namespace.yaml                           # Namespace definition
│   ├── deployment.yaml                          # App deployment
│   ├── service.yaml                             # Service (LoadBalancer)
│   ├── hpa.yaml                                 # Horizontal Pod Autoscaler
│   ├── prometheus-config.yaml                   # Prometheus ConfigMap
│   ├── prometheus-deployment.yaml               # Prometheus setup
│   └── grafana-deployment.yaml                  # Grafana setup
├── jmeter/                       # JMeter test scripts
│   └── load-test.jmx                            # Load test plan
├── scripts/                      # Helper scripts
│   ├── build-image.ps1                          # Build Docker image
│   ├── deploy.ps1                               # Deploy to K8s
│   ├── undeploy.ps1                             # Remove from K8s
│   ├── monitor.ps1                              # Real-time monitoring
│   └── run-load-test.ps1                        # Run JMeter test
├── Dockerfile                    # Docker build definition
├── .dockerignore                 # Docker ignore rules
├── pom.xml                       # Maven configuration
└── README.md                     # This file
```

## 🔧 Configuration

### HPA Settings (k8s/hpa.yaml):
- **Min Replicas**: 2
- **Max Replicas**: 10
- **CPU Threshold**: 50%
- **Memory Threshold**: 70%
- **Scale Down Stabilization**: 300s (5 phút)
- **Scale Up Stabilization**: 0s (immediate)

### Resource Limits (k8s/deployment.yaml):
```yaml
resources:
  requests:
    memory: "256Mi"
    cpu: "250m"
  limits:
    memory: "512Mi"
    cpu: "500m"
```

## 📝 Troubleshooting

### 1. Pods không start:
```powershell
kubectl describe pod <pod-name> -n k8s-demo
kubectl logs <pod-name> -n k8s-demo
```

### 2. HPA không hoạt động:
```powershell
# Kiểm tra metrics server
kubectl top nodes
kubectl top pods -n k8s-demo

# Nếu lỗi, install metrics server:
kubectl apply -f https://github.com/kubernetes-sigs/metrics-server/releases/latest/download/components.yaml
```

### 3. Service không accessible:
```powershell
# Kiểm tra service
kubectl get svc -n k8s-demo

# Kiểm tra endpoints
kubectl get endpoints -n k8s-demo

# Port forward nếu cần
kubectl port-forward svc/k8s-demo-service -n k8s-demo 8080:80
```

### 4. Prometheus không scrape metrics:
```powershell
# Kiểm tra ConfigMap
kubectl get configmap prometheus-config -n k8s-demo -o yaml

# Restart Prometheus
kubectl rollout restart deployment/prometheus -n k8s-demo
```

## 📚 Tài liệu tham khảo

- [Kubernetes Documentation](https://kubernetes.io/docs/)
- [Spring Boot Actuator](https://docs.spring.io/spring-boot/docs/current/reference/html/actuator.html)
- [Prometheus Documentation](https://prometheus.io/docs/)
- [Grafana Documentation](https://grafana.com/docs/)
- [Apache JMeter](https://jmeter.apache.org/usermanual/index.html)
- [Horizontal Pod Autoscaler](https://kubernetes.io/docs/tasks/run-application/horizontal-pod-autoscale/)

## 📄 License

MIT License - Free to use for educational purposes

## 👥 Author

Created for K8s Demo Assignment - PTUDDN

---

**Happy Scaling! 🚀**

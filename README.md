# Midterm - Pipeline CI/CD với GitHub Actions và ArgoCD


> **Mô tả**: Triển khai pipeline CI/CD hoàn chỉnh cho 3 ứng dụng Spring Boot sử dụng GitHub Actions (CI) và ArgoCD (CD) với GitOps workflow.

##  Tổng quan dự án

Dự án này thực hiện một hệ thống DevOps hoàn chỉnh với:

-** Continuous Integration**: GitHub Actions tự động build, test, và đóng gói ứng dụng
- ** Continuous Deployment**: ArgoCD tự động deploy ứng dụng theo GitOps pattern
- ** Kubernetes Orchestration**: Quản lý container trên Docker Desktop
- ** Monitoring & Observability**: Prometheus + Grafana cho theo dõi hệ thống

### Các ứng dụng demo:

1. ** Docker App** - Spring Boot REST API với MySQL
2. ** K8s Demo App** - Kubernetes native application với auto-scaling  
3. ** SSO App** - Authentication service với Auth0 OIDC


##  Quick Start

### 1. Chuẩn bị môi trường

**Yêu cầu hệ thống:**
```bash
✅ Docker Desktop với Kubernetes enabled
✅ kubectl CLI tool
✅ Git và GitHub account
✅ Java 21+ và Maven 3.8+
```

### 2. Clone repository

```bash
git clone https://github.com/mihuyen/PTUDDN-assign.git
cd PTUDDN-assign
```

### 3. Cài đặt ArgoCD

```bash
# Tạo namespace cho ArgoCD
kubectl create namespace argocd

# Cài đặt ArgoCD
kubectl apply -n argocd -f https://raw.githubusercontent.com/argoproj/argo-cd/stable/manifests/install.yaml

# Đợi pods khởi động (2-3 phút)
kubectl wait --for=condition=Ready pods --all -n argocd --timeout=300s

# Lấy mật khẩu admin
kubectl -n argocd get secret argocd-initial-admin-secret -o jsonpath="{.data.password}" | base64 -d
```

### 4. Truy cập ArgoCD UI

```bash
# Port forward ArgoCD server
kubectl port-forward svc/argocd-server -n argocd 8080:443
<img width="737" height="156" alt="image" src="https://github.com/user-attachments/assets/bb1600d9-72b3-40dc-a83d-2a194a558328" />

 **Truy cập**: https://localhost:8080
-  **Username**: `admin`  
-  **Password**: (từ lệnh trên)

![ArgoCD Login](https://github.com/user-attachments/assets/0213fcbb-f585-484a-8fe8-372d6fc0b305)

### 5. Deploy ArgoCD Applications

```bash
# Deploy tất cả applications
kubectl apply -f argocd/applications/app-of-apps.yaml

# Kiểm tra status
kubectl get applications -n argocd
```
<img width="738" height="258" alt="image" src="https://github.com/user-attachments/assets/94a2a247-1c3f-4bdb-a9f9-dba5cdff9575" />
<img width="1004" height="525" alt="image" src="https://github.com/user-attachments/assets/8d2b0775-f33a-46f9-91ac-7fc5fd77a1ec" />
<img width="1004" height="514" alt="image" src="https://github.com/user-attachments/assets/fcd34319-48e7-42ec-bca2-8938c4e312d1" />
<img width="1004" height="509" alt="image" src="https://github.com/user-attachments/assets/e7fdbed1-a4ea-4e04-948f-a720dc359b32" />




##  Thiết lập Pipeline CI (GitHub Actions)
### Cấu hình GitHub Secrets

Để pipeline hoạt động, cần thêm các secrets sau trong repository settings:

```bash
Repository Settings → Secrets and variables → Actions → New repository secret
```

| Secret Name | Description | Example Value |
|-------------|-------------|---------------|
| `DOCKER_USERNAME` | Docker Hub username | `your-username` |
| `DOCKER_PASSWORD` | Docker Hub password/token | `dckr_pat_xxxxx` |
| `GHCR_TOKEN` | GitHub Container Registry token | `ghp_xxxxx` |
| `ARGOCD_TOKEN` | ArgoCD API token (optional) | `argocd-server-xxxxx` |

<img width="1694" height="883" alt="image" src="https://github.com/user-attachments/assets/3678cc0a-e5b1-4717-9d7b-42fa30273abd" />
<img width="1195" height="566" alt="image" src="https://github.com/user-attachments/assets/d050398d-2ec3-4d7c-9dca-7305e9038e44" />



![GitHub Secrets](https://github.com/user-attachments/assets/57a73b9c-2c70-4a29-a424-9f7bcad591be)

##  CI/CD Workflow

### GitHub Actions CI Pipeline

**Trigger events:**
- ✅ Push to `main` branch
- ✅ Pull Request creation  
- ✅ Manual workflow dispatch

**Pipeline stages:**

```yaml
📋 Change Detection → 🧪 Test Modules → 🏗️ Build Modules → 🐳 Docker Images → 🔒 Security Scan → 📊 Reports
```

**Parallel Jobs:**
1. **Test Jobs** - Unit tests cho từng module
2. ** Build Jobs** - Maven build và JAR creation  
3. ** Docker Jobs** - Container image build & push
4. ** Security Jobs** - Vulnerability scanning với Trivy

### ArgoCD GitOps Deployment

**App of Apps Pattern:**
```yaml
app-of-apps:
  ├── docker-app-staging      # Auto-sync enabled
  ├── docker-app-production   # Manual sync for safety
  ├── k8s-demo-staging        # Auto-sync enabled  
  ├── k8s-demo-production     # Manual sync for safety
  └── monitoring-stack        # Prometheus + Grafana
```

**Deployment Flow:**
```
1. 📝 Code Push → GitHub
2. 🔄 CI Pipeline → Build & Test  
3. 🐳 Container → GitHub Container Registry
4. 📝 Manifest Update → Git Repository
5. 👁️ ArgoCD Detection → Monitor Git
6. 🔄 Auto Sync → Deploy to K8s
7. 🏥 Health Check → Validate Deployment
```




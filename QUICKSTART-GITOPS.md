# 🚀 Quick Start Guide: Complete CI/CD + GitOps Setup

This guide will walk you through setting up the complete CI/CD pipeline with ArgoCD GitOps for your multi-module Spring Boot project.

## 📋 Prerequisites

- Kubernetes cluster (minikube, kind, or cloud-managed)
- kubectl configured and connected to your cluster
- Docker installed
- Git repository access

## 🎯 Step-by-Step Setup

### 1. 📦 Install ArgoCD

#### On Windows (PowerShell):
```powershell
# Navigate to project directory
cd "E:\Ses1Year3\PTUDDN-assign"

# Run ArgoCD installation script
.\argocd\setup\install-argocd.ps1
```

#### On Linux/macOS:
```bash
# Navigate to project directory
cd /path/to/PTUDDN-assign

# Make scripts executable
chmod +x argocd/setup/*.sh

# Run ArgoCD installation script
./argocd/setup/install-argocd.sh
```

### 2. 🌐 Access ArgoCD UI

```bash
# Port forward to access ArgoCD UI
kubectl port-forward svc/argocd-server -n argocd 8080:443

# Get initial admin password
kubectl -n argocd get secret argocd-initial-admin-secret -o jsonpath="{.data.password}" | base64 -d
```

**Open your browser**: http://localhost:8080
- **Username**: `admin`
- **Password**: Use the output from the command above

### 3. 🔐 Setup GitHub Registry Access

```bash
# Create GitHub token secret for ArgoCD to access your container registry
kubectl create secret generic github-token \
  --from-literal=token=YOUR_GITHUB_TOKEN \
  -n argocd
```

### 4. 🚀 Deploy Applications Using App of Apps

```bash
# Deploy all applications at once using App of Apps pattern
kubectl apply -f argocd/applications/app-of-apps.yaml
```

This will automatically deploy:
- ✅ Docker App (Staging & Production)
- ✅ K8s Demo App (Staging & Production)  
- ✅ Monitoring Stack (Prometheus & Grafana)

### 5. 🔄 Install ArgoCD Image Updater (Optional)

```bash
# Install Image Updater for automatic image updates
./argocd/setup/install-image-updater.sh
```

### 6. ✅ Verify Deployment

```bash
# Check ArgoCD applications
kubectl get applications -n argocd

# Check application pods
kubectl get pods -A | grep -E "(docker|k8s-demo|monitoring)"

# Check ArgoCD UI for application status
```

## 🌍 Environment Overview

### 🔵 Staging Environment
- **Branch**: `develop`
- **Sync**: Automated
- **Apps**: 
  - `docker-app-staging` → `docker-staging` namespace
  - `k8s-demo-staging` → `k8s-demo-staging` namespace

### 🟢 Production Environment  
- **Branch**: `main`
- **Sync**: Manual (for safety)
- **Apps**:
  - `docker-app-production` → `docker-production` namespace
  - `k8s-demo-production` → `k8s-demo-production` namespace

### 📊 Monitoring
- **Prometheus**: `monitoring` namespace
- **Grafana**: `monitoring` namespace

## 🔄 GitOps Workflow

### Automatic Flow (Staging)
1. Push code to `develop` branch
2. GitHub Actions builds and tests
3. Docker images pushed to ghcr.io
4. GitOps workflow updates manifests
5. ArgoCD syncs automatically ✨

### Manual Flow (Production)
1. Merge to `main` branch
2. GitHub Actions builds and tests  
3. Docker images pushed to ghcr.io
4. GitOps workflow updates manifests
5. **Manual sync in ArgoCD UI** 🔒

## 🛠️ Common Commands

### ArgoCD CLI Commands
```bash
# Install ArgoCD CLI
curl -sSL -o argocd-linux-amd64 https://github.com/argoproj/argo-cd/releases/latest/download/argocd-linux-amd64
sudo install -m 555 argocd-linux-amd64 /usr/local/bin/argocd

# Login to ArgoCD
argocd login localhost:8080

# List applications
argocd app list

# Sync application manually
argocd app sync docker-app-production

# Check application status
argocd app get k8s-demo-staging
```

### Kubectl Commands
```bash
# Check all ArgoCD applications
kubectl get applications -n argocd

# Check application logs
kubectl logs -f deployment/argocd-application-controller -n argocd

# Check image updater logs
kubectl logs -f deployment/argocd-image-updater -n argocd
```

## 🔍 Monitoring & Verification

### Check Application Health
```bash
# View application status in ArgoCD UI
http://localhost:8080

# Or use CLI
argocd app list
argocd app get <app-name>
```

### Access Your Applications
```bash
# Port forward to your applications
kubectl port-forward svc/springboot-app -n docker-staging 8081:8080
kubectl port-forward svc/k8s-demo-service -n k8s-demo-staging 8082:8080

# Access applications
curl http://localhost:8081/actuator/health
curl http://localhost:8082/actuator/health
```

### Access Monitoring
```bash
# Port forward to Grafana
kubectl port-forward svc/grafana -n monitoring 3000:3000

# Access Grafana
http://localhost:3000
```

## 🚨 Troubleshooting

### ArgoCD Not Syncing
```bash
# Check application events
argocd app get <app-name> --show-events

# Force refresh
argocd app refresh <app-name>

# Hard sync
argocd app sync <app-name> --force
```

### Image Pull Issues
```bash
# Check registry credentials
kubectl get secrets -n <namespace>

# Verify image exists
docker pull ghcr.io/mihuyen/ptuddn-assign/docker:latest
```

### Application Not Starting
```bash
# Check pod logs
kubectl logs -f deployment/<deployment-name> -n <namespace>

# Check events
kubectl get events -n <namespace> --sort-by='.lastTimestamp'
```

## 🎉 Success Indicators

You'll know everything is working when:

1. ✅ **ArgoCD UI shows all apps as "Healthy" and "Synced"**
2. ✅ **Applications respond to health checks**
3. ✅ **New commits to develop/main trigger automatic deployments**
4. ✅ **Monitoring shows application metrics**
5. ✅ **GitHub Actions CI/CD pipeline passes**

## 📚 Next Steps

1. **Configure Slack notifications** (optional)
2. **Set up branch protection rules**
3. **Configure production approvals**
4. **Add more monitoring and alerting**
5. **Implement blue-green or canary deployments**

## 🆘 Need Help?

- **ArgoCD Documentation**: https://argo-cd.readthedocs.io/
- **Project Issues**: https://github.com/mihuyen/PTUDDN-assign/issues
- **ArgoCD Community**: https://argoproj.github.io/community/

---

**🎯 You now have a complete GitOps pipeline!** 

- **CI**: GitHub Actions builds, tests, and pushes images
- **CD**: ArgoCD deploys applications from Git manifests  
- **Monitoring**: Prometheus & Grafana for observability
- **Multi-environment**: Staging (auto) + Production (manual)
# ArgoCD GitOps Setup

This directory contains the ArgoCD configuration for implementing GitOps continuous deployment for the multi-module project.

## 🏗️ Architecture Overview

```
┌─────────────────┐    ┌─────────────────┐    ┌─────────────────┐
│   GitHub Repo   │    │     ArgoCD      │    │   Kubernetes    │
│                 │    │                 │    │                 │
│ ┌─────────────┐ │    │ ┌─────────────┐ │    │ ┌─────────────┐ │
│ │ CI Pipeline │ │───▶│ │ Applications│ │───▶│ │ Deployments │ │
│ └─────────────┘ │    │ └─────────────┘ │    │ └─────────────┘ │
│                 │    │                 │    │                 │
│ ┌─────────────┐ │    │ ┌─────────────┐ │    │ ┌─────────────┐ │
│ │ K8s Manifests│ │◀───│ │Image Updater│ │    │ │  Services   │ │
│ └─────────────┘ │    │ └─────────────┘ │    │ └─────────────┘ │
└─────────────────┘    └─────────────────┘    └─────────────────┘
```

## 📁 Directory Structure

```
argocd/
├── applications/           # ArgoCD Application definitions
│   ├── app-of-apps.yaml   # App of Apps pattern
│   ├── docker-app-staging.yaml
│   ├── docker-app-production.yaml
│   ├── k8s-demo-staging.yaml
│   ├── k8s-demo-production.yaml
│   └── monitoring-stack.yaml
├── setup/                 # Installation and configuration
│   ├── install-argocd.sh
│   ├── install-argocd.ps1
│   ├── install-image-updater.sh
│   ├── namespace.yaml
│   └── image-updater-config.yaml
└── overlays/              # Kustomize overlays for environments
    ├── staging/
    │   ├── kustomization.yaml
    │   ├── deployment-patch.yaml
    │   └── hpa-patch.yaml
    └── production/
        ├── kustomization.yaml
        ├── deployment-patch.yaml
        ├── hpa-patch.yaml
        └── service-patch.yaml
```

## 🚀 Quick Start

### 1. Install ArgoCD

#### On Linux/macOS:
```bash
chmod +x argocd/setup/install-argocd.sh
./argocd/setup/install-argocd.sh
```

#### On Windows:
```powershell
.\argocd\setup\install-argocd.ps1
```

### 2. Access ArgoCD UI

```bash
# Port forward to access ArgoCD UI
kubectl port-forward svc/argocd-server -n argocd 8080:443

# Get initial admin password
kubectl -n argocd get secret argocd-initial-admin-secret -o jsonpath="{.data.password}" | base64 -d
```

Access ArgoCD at: **http://localhost:8080**
- Username: `admin`
- Password: Use the command above to get the initial password

### 3. Deploy Applications

#### Option A: App of Apps Pattern (Recommended)
```bash
kubectl apply -f argocd/applications/app-of-apps.yaml
```

#### Option B: Individual Applications
```bash
kubectl apply -f argocd/applications/
```

### 4. Install ArgoCD Image Updater (Optional)
```bash
chmod +x argocd/setup/install-image-updater.sh
./argocd/setup/install-image-updater.sh

# Create GitHub token secret for image registry access
kubectl create secret generic github-token \
  --from-literal=token=<your-github-token> \
  -n argocd
```

## 🎯 Applications

### Docker App
- **Staging**: `docker-app-staging` - Tracks `develop` branch
- **Production**: `docker-app-production` - Tracks `main` branch
- **Path**: `docker/k8s/`
- **Namespace**: `docker-staging` / `docker-production`

### K8s Demo App
- **Staging**: `k8s-demo-staging` - Tracks `develop` branch
- **Production**: `k8s-demo-production` - Tracks `main` branch
- **Path**: `k8s/k8s/`
- **Namespace**: `k8s-demo-staging` / `k8s-demo-production`

### Monitoring Stack
- **Application**: `monitoring-stack` - Tracks `main` branch
- **Path**: `k8s/k8s/` (Prometheus and Grafana manifests)
- **Namespace**: `monitoring`

## 🔄 GitOps Workflow

### Automatic Deployment Flow

1. **Developer pushes code** to `develop` or `main` branch
2. **GitHub Actions CI/CD pipeline** builds and tests the application
3. **Docker images** are built and pushed to GitHub Container Registry
4. **GitOps workflow** updates Kubernetes manifests with new image tags
5. **ArgoCD detects changes** and syncs applications
6. **Applications are deployed** to the appropriate environment

### Manual Deployment

```bash
# Sync specific application
argocd app sync docker-app-staging

# Sync all applications
argocd app sync -l environment=staging

# Hard refresh (ignore cache)
argocd app sync docker-app-production --force
```

## 🌍 Environments

### Staging Environment
- **Branch**: `develop`
- **Sync Policy**: Automated (prune: true, selfHeal: true)
- **Image Strategy**: Latest tags from develop branch
- **Resources**: Lower resource limits for cost optimization
- **Replicas**: 2 minimum, 5 maximum

### Production Environment
- **Branch**: `main`
- **Sync Policy**: Manual sync for safety
- **Image Strategy**: Semantic versioning tags
- **Resources**: Higher resource limits for performance
- **Replicas**: 3 minimum, 10 maximum
- **Load Balancer**: Enabled for external access

## 🔧 Configuration

### Sync Policies

**Staging (Automated)**:
```yaml
syncPolicy:
  automated:
    prune: true      # Remove resources not in Git
    selfHeal: true   # Auto-sync when drift detected
```

**Production (Manual)**:
```yaml
syncPolicy:
  automated:
    prune: false     # Manual pruning for safety
    selfHeal: false  # Manual sync for production
```

### Image Update Strategies

- **Staging**: `latest` - Always use the latest image from develop branch
- **Production**: `semver` - Use semantic versioning for stable releases

### Health Checks

ArgoCD monitors application health using:
- Kubernetes resource status
- Custom health checks for specific resources
- Application-level health endpoints

## 🔐 Security

### RBAC Configuration

ArgoCD uses Kubernetes RBAC for access control:
- **Developers**: Read access to staging applications
- **DevOps**: Full access to all applications
- **Production**: Restricted access with approval workflows

### Secret Management

- Secrets are stored in Kubernetes Secret resources
- ArgoCD can sync secrets from Git (not recommended for sensitive data)
- Use external secret management tools like:
  - External Secrets Operator
  - Sealed Secrets
  - Vault integration

### Network Policies

```yaml
# Example network policy for ArgoCD
apiVersion: networking.k8s.io/v1
kind: NetworkPolicy
metadata:
  name: argocd-network-policy
spec:
  # Network policy configuration
```

## 📊 Monitoring

### ArgoCD Metrics

ArgoCD exposes Prometheus metrics for monitoring:
- Application sync status
- Sync frequency and duration
- Resource health status
- Git repository status

### Grafana Dashboards

Import ArgoCD dashboards:
- ArgoCD Application Overview
- ArgoCD Sync Performance
- ArgoCD Resource Health

### Alerts

Configure alerts for:
- Failed application syncs
- Out-of-sync applications
- Resource health issues
- Image update failures

## 🚨 Troubleshooting

### Common Issues

#### 1. Application Stuck in Syncing
```bash
# Check application status
argocd app get <app-name>

# Check sync operation
argocd app sync <app-name> --dry-run

# Force sync
argocd app sync <app-name> --force
```

#### 2. Image Pull Errors
```bash
# Check image registry credentials
kubectl get secrets -n <namespace>

# Verify image exists
docker pull <image-name>:<tag>
```

#### 3. Resource Health Issues
```bash
# Check resource status
kubectl describe <resource-type> <resource-name> -n <namespace>

# Check ArgoCD application events
argocd app get <app-name> --show-events
```

#### 4. Sync Policy Issues
```bash
# Check diff between Git and cluster
argocd app diff <app-name>

# Refresh application
argocd app refresh <app-name>
```

### Useful Commands

```bash
# List all applications
argocd app list

# Get application details
argocd app get <app-name>

# View application logs
argocd app logs <app-name>

# Check application history
argocd app history <app-name>

# Rollback application
argocd app rollback <app-name> <revision>
```

## 🔄 CI/CD Integration

### GitHub Actions Integration

The project includes a GitOps workflow (`.github/workflows/gitops.yml`) that:

1. **Triggers** after successful CI/CD pipeline completion
2. **Updates** Kubernetes manifests with new image tags
3. **Commits** changes back to the repository
4. **Notifies** ArgoCD of the changes (optional)

### Image Registry Integration

- **Registry**: GitHub Container Registry (ghcr.io)
- **Authentication**: GitHub token for private repositories
- **Image Updater**: Automatically updates image tags in manifests

## 📚 Best Practices

### 1. Git Repository Structure
- Keep application manifests in the same repository as source code
- Use separate branches for different environments
- Implement proper branching strategy (GitFlow)

### 2. Application Management
- Use App of Apps pattern for managing multiple applications
- Implement proper resource naming and labeling
- Use Kustomize overlays for environment-specific configurations

### 3. Security
- Never store secrets in Git repositories
- Use proper RBAC configurations
- Implement network policies
- Regular security audits

### 4. Monitoring
- Monitor application health and sync status
- Set up alerts for critical issues
- Use GitOps metrics for optimization

### 5. Testing
- Test manifests in staging before production
- Use dry-run for validation
- Implement proper rollback procedures

## 🆘 Support

### Documentation
- [ArgoCD Official Documentation](https://argo-cd.readthedocs.io/)
- [Kustomize Documentation](https://kustomize.io/)
- [GitOps Best Practices](https://www.gitops.tech/)

### Community
- [ArgoCD Slack](https://argoproj.github.io/community/join-slack)
- [ArgoCD GitHub Issues](https://github.com/argoproj/argo-cd/issues)
- [CNCF GitOps Working Group](https://github.com/cncf/tag-app-delivery)

## 🎉 Success Metrics

Track these metrics to measure GitOps success:

- **Deployment Frequency**: How often you deploy to production
- **Lead Time**: Time from code commit to production deployment
- **Mean Time to Recovery**: Time to recover from failed deployments
- **Change Failure Rate**: Percentage of deployments that cause issues

With this ArgoCD setup, you'll have a robust GitOps workflow that provides:
- ✅ Automated deployments
- ✅ Environment promotion
- ✅ Rollback capabilities
- ✅ Audit trails
- ✅ Security and compliance
#!/bin/bash

# ArgoCD Installation and Setup Script
set -e

echo "🚀 Installing ArgoCD..."

# Create ArgoCD namespace
kubectl create namespace argocd --dry-run=client -o yaml | kubectl apply -f -

# Install ArgoCD
echo "📦 Installing ArgoCD components..."
kubectl apply -n argocd -f https://raw.githubusercontent.com/argoproj/argo-cd/stable/manifests/install.yaml

# Wait for ArgoCD to be ready
echo "⏳ Waiting for ArgoCD to be ready..."
kubectl wait --for=condition=available --timeout=600s deployment/argocd-server -n argocd
kubectl wait --for=condition=available --timeout=600s deployment/argocd-application-controller -n argocd
kubectl wait --for=condition=available --timeout=600s deployment/argocd-dex-server -n argocd

# Get initial admin password
echo "🔑 Getting initial admin password..."
ARGOCD_PASSWORD=$(kubectl -n argocd get secret argocd-initial-admin-secret -o jsonpath="{.data.password}" | base64 -d)

echo "✅ ArgoCD installation completed!"
echo ""
echo "📋 Access Information:"
echo "🌐 ArgoCD UI: http://localhost:8080"
echo "👤 Username: admin"
echo "🔐 Password: $ARGOCD_PASSWORD"
echo ""
echo "🚀 To access ArgoCD UI, run:"
echo "kubectl port-forward svc/argocd-server -n argocd 8080:443"
echo ""
echo "📚 Next steps:"
echo "1. Access ArgoCD UI"
echo "2. Change admin password"
echo "3. Install ArgoCD applications: kubectl apply -f argocd/applications/"
echo "4. Configure repositories and sync policies"

# Optionally patch ArgoCD server for insecure mode (development only)
echo ""
read -p "🔒 Enable insecure mode for development? (y/N): " -n 1 -r
echo
if [[ $REPLY =~ ^[Yy]$ ]]; then
    echo "⚠️  Enabling insecure mode (not recommended for production)..."
    kubectl patch deployment argocd-server -n argocd --patch='{"spec":{"template":{"spec":{"containers":[{"name":"argocd-server","args":["argocd-server","--insecure"]}]}}}}'
    kubectl rollout status deployment/argocd-server -n argocd
    echo "✅ Insecure mode enabled. You can now access ArgoCD at http://localhost:8080"
fi

echo ""
echo "🎉 ArgoCD setup completed successfully!"
#!/bin/bash

# ArgoCD Image Updater Installation Script
set -e

echo "🔄 Installing ArgoCD Image Updater..."

# Install ArgoCD Image Updater
echo "📦 Installing ArgoCD Image Updater components..."
kubectl apply -n argocd -f https://raw.githubusercontent.com/argoproj-labs/argocd-image-updater/stable/manifests/install.yaml

# Apply custom configuration
echo "⚙️  Applying custom configuration..."
kubectl apply -f argocd/setup/image-updater-config.yaml

# Wait for Image Updater to be ready
echo "⏳ Waiting for ArgoCD Image Updater to be ready..."
kubectl wait --for=condition=available --timeout=300s deployment/argocd-image-updater -n argocd

echo "✅ ArgoCD Image Updater installation completed!"
echo ""
echo "📋 Image Updater Features:"
echo "🔄 Automatic image updates for new tags"
echo "🏷️  Support for latest and semver update strategies"
echo "📝 Git write-back for manifest updates"
echo "🔐 Registry authentication support"
echo ""
echo "🚀 Next steps:"
echo "1. Create GitHub token secret:"
echo "   kubectl create secret generic github-token --from-literal=token=<your-github-token> -n argocd"
echo "2. Configure applications with image update annotations"
echo "3. Monitor image updates in ArgoCD UI"
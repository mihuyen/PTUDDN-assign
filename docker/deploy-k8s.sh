#!/bin/bash

echo "Deploying application to Kubernetes..."

# Apply ConfigMap
echo "Creating ConfigMap..."
kubectl apply -f k8s/app-configmap.yaml

# Apply MySQL PV and PVC
echo "Creating MySQL Persistent Volume..."
kubectl apply -f k8s/mysql-pv.yaml

# Apply MySQL Deployment
echo "Deploying MySQL..."
kubectl apply -f k8s/mysql-deployment.yaml

# Wait for MySQL to be ready
echo "Waiting for MySQL to be ready..."
kubectl wait --for=condition=ready pod -l app=mysql --timeout=300s

# Apply SpringBoot App Deployment
echo "Deploying SpringBoot Application..."
kubectl apply -f k8s/app-deployment.yaml

# Wait for app to be ready
echo "Waiting for SpringBoot App to be ready..."
kubectl wait --for=condition=ready pod -l app=springboot-app --timeout=300s

# Show status
echo "Deployment completed!"
echo "Getting pods status:"
kubectl get pods

echo "Getting services:"
kubectl get services

echo "Application URL: http://localhost:30080"
echo "Health check: http://localhost:30080/actuator/health"
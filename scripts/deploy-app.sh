#!/bin/bash

# Скрипт для развертывания приложения
set -e

PROJECT_DIR="$(cd "$(dirname "$0")/.." && pwd)"
REGISTRY_ID="${1:-<registry_id>}"

echo "=== Deploying Application ==="

# Обновление image в deployment
echo "Updating deployment with registry ID: ${REGISTRY_ID}"
sed -i.bak "s/<registry_id>/${REGISTRY_ID}/g" "${PROJECT_DIR}/kubernetes/app/deployment.yaml"

# Применение манифестов
echo "Applying Kubernetes manifests..."
kubectl apply -f "${PROJECT_DIR}/kubernetes/app/deployment.yaml"

# Ожидание готовности
echo "Waiting for deployment to be ready..."
kubectl rollout status deployment/diploma-app -n default --timeout=300s

echo ""
echo "=== Application Deployed ==="
echo ""
echo "Pods:"
kubectl get pods -l app=diploma-app -n default

echo ""
echo "Service:"
kubectl get svc diploma-app-service -n default

echo ""
echo "Access: http://<node_ip>:30000"

#!/bin/bash

# Скрипт для развертывания мониторинга
set -e

PROJECT_DIR="$(cd "$(dirname "$0")/.." && pwd)"

echo "=== Deploying kube-prometheus-stack ==="

# Добавление репозитория Helm
echo "Adding Prometheus Helm repository..."
helm repo add prometheus-community https://prometheus-community.github.io/helm-charts
helm repo update

# Установка стека
echo "Installing kube-prometheus-stack..."
helm upgrade --install monitoring prometheus-community/kube-prometheus-stack \
  --namespace monitoring \
  --create-namespace \
  --values "${PROJECT_DIR}/kubernetes/monitoring/values-monitoring.yaml" \
  --wait

echo ""
echo "=== Monitoring Stack Deployed ==="
echo ""
echo "Services:"
kubectl get svc -n monitoring

echo ""
echo "Access:"
echo "- Grafana: http://<node_ip>:30080"
echo "  Username: admin"
echo "  Password: securePassword123 (change in values-monitoring.yaml)"

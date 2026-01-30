#!/bin/bash

# Скрипт для создания секретов Atlantis
# Заполните переменные перед запуском

set -e

# Конфигурация - заполните эти значения
GITHUB_USER="<YOUR_GITHUB_USER>"
GITHUB_TOKEN="<YOUR_GITHUB_TOKEN>"
YC_OAUTH_TOKEN="<YC_OAUTH_TOKEN>"
YC_CLOUD_ID="<YC_CLOUD_ID>"
YC_FOLDER_ID="<YC_FOLDER_ID>"
S3_ACCESS_KEY="<S3_ACCESS_KEY>"
S3_SECRET_KEY="<S3_SECRET_KEY>"

# Генерация webhook secret
WEBHOOK_SECRET=$(openssl rand -hex 32)

echo "Generated Webhook Secret: $WEBHOOK_SECRET"
echo "Save this value for GitHub webhook configuration!"
echo ""

# Создание namespace
kubectl create namespace atlantis --dry-run=client -o yaml | kubectl apply -f -

# Создание секретов
kubectl create secret generic atlantis-secrets \
  --namespace atlantis \
  --from-literal=github-user="$GITHUB_USER" \
  --from-literal=github-token="$GITHUB_TOKEN" \
  --from-literal=webhook-secret="$WEBHOOK_SECRET" \
  --from-literal=yc-token="$YC_OAUTH_TOKEN" \
  --from-literal=yc-cloud-id="$YC_CLOUD_ID" \
  --from-literal=yc-folder-id="$YC_FOLDER_ID" \
  --from-literal=s3-access-key="$S3_ACCESS_KEY" \
  --from-literal=s3-secret-key="$S3_SECRET_KEY" \
  --dry-run=client -o yaml | kubectl apply -f -

echo ""
echo "Secrets created successfully!"
echo ""
echo "Next steps:"
echo "1. Configure GitHub webhook:"
echo "   - Payload URL: http://<atlantis-ip>:30141/events"
echo "   - Content type: application/json"
echo "   - Secret: $WEBHOOK_SECRET"
echo "   - Events: Pull requests, Issue comments, Push"
echo ""
echo "2. Deploy Atlantis:"
echo "   kubectl apply -f kubernetes/atlantis/"

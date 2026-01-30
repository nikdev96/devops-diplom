# DevOps Diploma Project

Развертывание облачной инфраструктуры в Yandex Cloud с Kubernetes кластером, системой мониторинга и CI/CD пайплайном.

## Структура проекта

```
.
├── terraform/
│   ├── 00-sa-bucket/     # Сервисный аккаунт и S3 bucket
│   ├── 01-network/       # VPC и подсети
│   ├── 02-compute/       # ВМ для K8s кластера
│   └── 03-registry/      # Container Registry
├── ansible/
│   ├── inventory/        # Inventory для Kubespray
│   └── generate-inventory.sh
├── kubernetes/
│   ├── app/              # Манифесты приложения
│   ├── monitoring/       # Конфигурация мониторинга
│   └── atlantis/         # Atlantis для Terraform PR
├── app/                  # Тестовое приложение
├── scripts/              # Вспомогательные скрипты
├── .github/workflows/    # CI/CD пайплайны
└── atlantis.yaml         # Конфигурация Atlantis
```

## Порядок развертывания

### 1. Настройка Yandex Cloud

```bash
# Установка yc CLI
curl -sSL https://storage.yandexcloud.net/yandexcloud-yc/install.sh | bash

# Инициализация
yc init

# Экспорт переменных
export YC_TOKEN=$(yc iam create-token)
export YC_CLOUD_ID=$(yc config get cloud-id)
export YC_FOLDER_ID=$(yc config get folder-id)
```

### 2. Terraform: Сервисный аккаунт и S3 bucket

```bash
cd terraform/00-sa-bucket
cp ../terraform.tfvars.example terraform.tfvars
# Заполните terraform.tfvars

terraform init
terraform apply

# Сохраните outputs для backend configuration
terraform output -raw access_key
terraform output -raw secret_key
terraform output -raw bucket_name
```

### 3. Terraform: VPC и подсети

```bash
cd terraform/01-network
# Обновите backend.tf с bucket name из предыдущего шага

export AWS_ACCESS_KEY_ID=<access_key>
export AWS_SECRET_ACCESS_KEY=<secret_key>

terraform init
terraform apply
```

### 4. Terraform: Compute (K8s nodes)

```bash
cd terraform/02-compute
terraform init
terraform apply
```

### 5. Terraform: Container Registry

```bash
cd terraform/03-registry
terraform init
terraform apply

# Получите registry ID для CI/CD
terraform output -raw registry_id
```

### 6. Kubespray: Kubernetes кластер

```bash
# Настройка Kubespray
./scripts/setup-kubespray.sh

# Генерация inventory из Terraform outputs
./ansible/generate-inventory.sh

# Развертывание кластера
cd kubespray
source venv/bin/activate
ansible-playbook -i inventory/diploma-cluster/hosts.yaml \
  --become --become-user=root \
  -u ubuntu \
  cluster.yml
```

### 7. Настройка kubectl

```bash
# Скопировать kubeconfig с master ноды
scp ubuntu@<master_ip>:/etc/kubernetes/admin.conf ~/.kube/config

# Проверка
kubectl get nodes
```

### 8. Развертывание мониторинга

```bash
./scripts/deploy-monitoring.sh
```

### 9. Развертывание приложения

```bash
./scripts/deploy-app.sh <registry_id>
```

### 10. Настройка Atlantis

```bash
# Создание секретов
./kubernetes/atlantis/create-secrets.sh

# Развертывание
kubectl apply -f kubernetes/atlantis/
```

## GitHub Secrets

Для CI/CD необходимо настроить следующие секреты в репозитории:

- `YC_REGISTRY_ID` - ID Container Registry
- `YC_SA_JSON_CREDENTIALS` - JSON ключ сервисного аккаунта
- `KUBE_CONFIG` - base64-encoded kubeconfig

```bash
# Получение JSON ключа
terraform -chdir=terraform/03-registry output -raw pusher_sa_key_json > sa-key.json
cat sa-key.json | base64

# Кодирование kubeconfig
cat ~/.kube/config | base64
```

## Endpoints

| Сервис | URL |
|--------|-----|
| Приложение | http://\<node_ip\>:30000 |
| Grafana | http://\<node_ip\>:30080 |
| Atlantis | http://\<node_ip\>:30141 |

## Верификация

```bash
# Проверка кластера
kubectl get nodes
kubectl get pods --all-namespaces

# Проверка приложения
curl http://<node_ip>:30000

# Проверка мониторинга
curl http://<node_ip>:30080

# Проверка Atlantis
curl http://<node_ip>:30141
```

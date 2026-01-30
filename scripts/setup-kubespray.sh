#!/bin/bash

# Скрипт для настройки Kubespray
set -e

KUBESPRAY_VERSION="v2.24.0"
PROJECT_DIR="$(cd "$(dirname "$0")/.." && pwd)"

echo "=== Setting up Kubespray ==="

# Клонирование Kubespray
if [ ! -d "${PROJECT_DIR}/kubespray" ]; then
    echo "Cloning Kubespray ${KUBESPRAY_VERSION}..."
    git clone --branch ${KUBESPRAY_VERSION} https://github.com/kubernetes-sigs/kubespray.git "${PROJECT_DIR}/kubespray"
else
    echo "Kubespray directory already exists"
fi

cd "${PROJECT_DIR}/kubespray"

# Создание виртуального окружения Python
echo "Setting up Python virtual environment..."
python3.12 -m venv venv
source venv/bin/activate

# Установка зависимостей
echo "Installing requirements..."
pip install -U pip
pip install -r requirements.txt

# Копирование inventory
echo "Copying inventory template..."
cp -rfp inventory/sample inventory/diploma-cluster 2>/dev/null || true

# Копирование нашего hosts.yaml
if [ -f "${PROJECT_DIR}/ansible/inventory/diploma-cluster/hosts.yaml" ]; then
    cp "${PROJECT_DIR}/ansible/inventory/diploma-cluster/hosts.yaml" inventory/diploma-cluster/
    echo "Copied hosts.yaml from ansible/inventory/"
fi

echo ""
echo "=== Setup Complete ==="
echo ""
echo "Next steps:"
echo "1. Update inventory/diploma-cluster/hosts.yaml with your VM IPs"
echo "   (run ansible/generate-inventory.sh after terraform apply)"
echo ""
echo "2. Run Kubespray:"
echo "   cd kubespray"
echo "   source venv/bin/activate"
echo "   ansible-playbook -i inventory/diploma-cluster/hosts.yaml \\"
echo "     --become --become-user=root \\"
echo "     -u ubuntu \\"
echo "     cluster.yml"

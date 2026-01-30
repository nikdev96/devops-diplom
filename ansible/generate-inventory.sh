#!/bin/bash

# Скрипт для генерации Kubespray inventory из Terraform outputs
# Запускать из директории terraform/02-compute

set -e

INVENTORY_DIR="../ansible/inventory/diploma-cluster"

# Получаем данные из Terraform
cd "$(dirname "$0")/../terraform/02-compute"

MASTER_EXTERNAL=$(terraform output -raw master_external_ip)
MASTER_INTERNAL=$(terraform output -raw master_internal_ip)
WORKER_EXTERNAL_1=$(terraform output -json worker_external_ips | jq -r '.[0]')
WORKER_EXTERNAL_2=$(terraform output -json worker_external_ips | jq -r '.[1]')
WORKER_INTERNAL_1=$(terraform output -json worker_internal_ips | jq -r '.[0]')
WORKER_INTERNAL_2=$(terraform output -json worker_internal_ips | jq -r '.[1]')

cd - > /dev/null

# Генерируем hosts.yaml
cat > "${INVENTORY_DIR}/hosts.yaml" << EOF
all:
  hosts:
    master:
      ansible_host: ${MASTER_EXTERNAL}
      ip: ${MASTER_INTERNAL}
      access_ip: ${MASTER_INTERNAL}
    worker-1:
      ansible_host: ${WORKER_EXTERNAL_1}
      ip: ${WORKER_INTERNAL_1}
      access_ip: ${WORKER_INTERNAL_1}
    worker-2:
      ansible_host: ${WORKER_EXTERNAL_2}
      ip: ${WORKER_INTERNAL_2}
      access_ip: ${WORKER_INTERNAL_2}
  children:
    kube_control_plane:
      hosts:
        master:
    kube_node:
      hosts:
        worker-1:
        worker-2:
    etcd:
      hosts:
        master:
    k8s_cluster:
      children:
        kube_control_plane:
        kube_node:
    calico_rr:
      hosts: {}
EOF

echo "Inventory generated successfully!"
echo ""
echo "Master: ${MASTER_EXTERNAL} (internal: ${MASTER_INTERNAL})"
echo "Worker-1: ${WORKER_EXTERNAL_1} (internal: ${WORKER_INTERNAL_1})"
echo "Worker-2: ${WORKER_EXTERNAL_2} (internal: ${WORKER_INTERNAL_2})"

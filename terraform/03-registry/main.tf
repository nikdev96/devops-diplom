resource "yandex_container_registry" "diploma-registry" {
  name      = "diploma-registry"
  folder_id = var.folder_id
}

# IAM binding для push/pull (если указан SA)
resource "yandex_container_registry_iam_binding" "puller" {
  count       = var.k8s_node_sa_id != "" ? 1 : 0
  registry_id = yandex_container_registry.diploma-registry.id
  role        = "container-registry.images.puller"
  members     = ["serviceAccount:${var.k8s_node_sa_id}"]
}

# Сервисный аккаунт для CI/CD (push образов)
resource "yandex_iam_service_account" "registry-pusher" {
  name        = "registry-pusher-sa"
  description = "Service account for pushing images to registry"
}

resource "yandex_container_registry_iam_binding" "pusher" {
  registry_id = yandex_container_registry.diploma-registry.id
  role        = "container-registry.images.pusher"
  members     = ["serviceAccount:${yandex_iam_service_account.registry-pusher.id}"]
}

# Ключ для CI/CD
resource "yandex_iam_service_account_key" "registry-pusher-key" {
  service_account_id = yandex_iam_service_account.registry-pusher.id
  description        = "Key for CI/CD to push images"
}

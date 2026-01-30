output "registry_id" {
  description = "Container registry ID"
  value       = yandex_container_registry.diploma-registry.id
}

output "registry_name" {
  description = "Container registry name"
  value       = yandex_container_registry.diploma-registry.name
}

output "pusher_sa_id" {
  description = "Registry pusher service account ID"
  value       = yandex_iam_service_account.registry-pusher.id
}

output "pusher_sa_key_id" {
  description = "Registry pusher service account key ID"
  value       = yandex_iam_service_account_key.registry-pusher-key.id
}

output "pusher_sa_key_json" {
  description = "Registry pusher service account key (JSON format for GitHub secrets)"
  value = jsonencode({
    id                 = yandex_iam_service_account_key.registry-pusher-key.id
    service_account_id = yandex_iam_service_account.registry-pusher.id
    created_at         = yandex_iam_service_account_key.registry-pusher-key.created_at
    key_algorithm      = yandex_iam_service_account_key.registry-pusher-key.key_algorithm
    public_key         = yandex_iam_service_account_key.registry-pusher-key.public_key
    private_key        = yandex_iam_service_account_key.registry-pusher-key.private_key
  })
  sensitive = true
}

output "service_account_id" {
  description = "Terraform service account ID"
  value       = yandex_iam_service_account.terraform.id
}

output "access_key" {
  description = "Static access key for S3"
  value       = yandex_iam_service_account_static_access_key.sa-static-key.access_key
  sensitive   = true
}

output "secret_key" {
  description = "Static secret key for S3"
  value       = yandex_iam_service_account_static_access_key.sa-static-key.secret_key
  sensitive   = true
}

output "bucket_name" {
  description = "S3 bucket name for Terraform state"
  value       = yandex_storage_bucket.terraform-state.bucket
}

variable "cloud_id" {
  description = "Yandex Cloud ID"
  type        = string
}

variable "folder_id" {
  description = "Yandex Cloud Folder ID"
  type        = string
}

variable "zone" {
  description = "Yandex Cloud default zone"
  type        = string
  default     = "ru-central1-a"
}

variable "k8s_node_sa_id" {
  description = "Service account ID for K8s nodes (for pulling images)"
  type        = string
  default     = ""
}

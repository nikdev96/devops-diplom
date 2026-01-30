output "master_external_ip" {
  description = "Master node external IP"
  value       = yandex_compute_instance.master.network_interface[0].nat_ip_address
}

output "master_internal_ip" {
  description = "Master node internal IP"
  value       = yandex_compute_instance.master.network_interface[0].ip_address
}

output "worker_external_ips" {
  description = "Worker nodes external IPs"
  value       = yandex_compute_instance.worker[*].network_interface[0].nat_ip_address
}

output "worker_internal_ips" {
  description = "Worker nodes internal IPs"
  value       = yandex_compute_instance.worker[*].network_interface[0].ip_address
}

# Вывод для удобства настройки Kubespray
output "kubespray_hosts" {
  description = "Hosts information for Kubespray inventory"
  value = {
    master = {
      ansible_host = yandex_compute_instance.master.network_interface[0].nat_ip_address
      ip           = yandex_compute_instance.master.network_interface[0].ip_address
    }
    workers = [
      for i, worker in yandex_compute_instance.worker : {
        name         = "worker-${i + 1}"
        ansible_host = worker.network_interface[0].nat_ip_address
        ip           = worker.network_interface[0].ip_address
      }
    ]
  }
}

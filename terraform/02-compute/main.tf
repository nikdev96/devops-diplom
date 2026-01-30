# Получение данных о сети из remote state
data "terraform_remote_state" "network" {
  backend = "s3"
  config = {
    endpoint                    = "https://storage.yandexcloud.net"
    bucket                      = "tfstate-diploma-${var.folder_id}"
    region                      = "ru-central1"
    key                         = "network/terraform.tfstate"
    skip_region_validation      = true
    skip_credentials_validation = true
    skip_metadata_api_check     = true
  }
}

# Получение последнего образа Ubuntu 22.04
data "yandex_compute_image" "ubuntu" {
  family = "ubuntu-2204-lts"
}

# Master node
resource "yandex_compute_instance" "master" {
  name        = "k8s-master"
  platform_id = "standard-v3"
  zone        = "ru-central1-a"

  resources {
    cores         = 2
    memory        = 4
    core_fraction = 20
  }

  scheduling_policy {
    preemptible = true
  }

  boot_disk {
    initialize_params {
      image_id = var.ubuntu_image_id != "" ? var.ubuntu_image_id : data.yandex_compute_image.ubuntu.id
      size     = 50
    }
  }

  network_interface {
    subnet_id = data.terraform_remote_state.network.outputs.subnet_a_id
    nat       = true
  }

  metadata = {
    ssh-keys = "ubuntu:${file(var.ssh_public_key_path)}"
  }
}

# Worker nodes (2 штуки в разных зонах)
resource "yandex_compute_instance" "worker" {
  count       = 2
  name        = "k8s-worker-${count.index + 1}"
  platform_id = "standard-v3"
  zone        = count.index == 0 ? "ru-central1-b" : "ru-central1-d"

  resources {
    cores         = 2
    memory        = 4
    core_fraction = 20
  }

  scheduling_policy {
    preemptible = true
  }

  boot_disk {
    initialize_params {
      image_id = var.ubuntu_image_id != "" ? var.ubuntu_image_id : data.yandex_compute_image.ubuntu.id
      size     = 50
    }
  }

  network_interface {
    subnet_id = count.index == 0 ? data.terraform_remote_state.network.outputs.subnet_b_id : data.terraform_remote_state.network.outputs.subnet_d_id
    nat       = true
  }

  metadata = {
    ssh-keys = "ubuntu:${file(var.ssh_public_key_path)}"
  }
}

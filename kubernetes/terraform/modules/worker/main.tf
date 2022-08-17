terraform {
  required_providers {
    yandex = {
      source  = "yandex-cloud/yandex"
      version = "0.74.0"
    }
  }
  required_version = ">= 0.13"
}
data "yandex_compute_image" "container-optimized-image-worker" {
  name = var.worker_disk_image
}
resource "yandex_compute_instance" "k8s_worker" {
  count  = var.yc_instance_app_count
  name   = "reddit-worker-k8s${count.index}"

  allow_stopping_for_update = true
  resources {
    cores  = 4
    memory = 4
  }

  boot_disk {
    initialize_params {
      # Указать id образа созданного в предыдущем домашем задании
      image_id = data.yandex_compute_image.container-optimized-image-worker.id
    }
  }

  metadata = {
    ssh-keys = "ubuntu:${file(var.public_key_path)}"
  }

  network_interface {
    # Указан id подсети default-ru-central1-a
    subnet_id = var.subnet_id
    nat       = true
  }
  connection {
    type  = "ssh"
    host  = self.network_interface.0.nat_ip_address
    user  = "ubuntu"
    agent = false
    # путь до приватного ключа
    private_key = file(var.private_key_path)
  }
}

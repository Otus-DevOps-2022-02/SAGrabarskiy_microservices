terraform {
  required_providers {
    yandex = {
      source  = "yandex-cloud/yandex"
      version = "0.74.0"
    }
  }
  required_version = ">= 0.13"
}

provider "yandex" {
  service_account_key_file = var.service_account_key_file
  cloud_id                 = var.cloud_id
  folder_id                = var.folder_id
  zone                     = var.yc_instance_zone
}
module "worker" {
  source           = "../modules/worker"
  public_key_path  = var.public_key_path
  private_key_path = var.private_key_path
  worker_disk_image   = var.worker_disk_image
  subnet_id        = var.subnet_id
  reddit_worker_name  = var.reddit_worker_name
  yc_instance_app_count = var.yc_instance_app_count  
  master_ip        = module.master.external_ip_address_master
}
module "master" {
  source           = "../modules/master"
  public_key_path  = var.public_key_path
  private_key_path = var.private_key_path
  master_disk_image    = var.master_disk_image
  subnet_id        = var.subnet_id
  reddit_master_name   = var.reddit_master_name
}

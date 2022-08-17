variable "cloud_id" {}
variable "folder_id" {}
variable "yc_instance_zone" { default = "ru-central1-a" }
variable "public_key_path" {}
variable "private_key_path" {}
variable "image_id" {}
variable "subnet_id" {}
variable "reddit_worker_name" {}
variable "reddit_master_name" {}
variable "service_account_key_file" { default = "key.json" }
variable "worker_disk_image" {
  description = "Disk image for reddit app"
  default     = "reddit-k8s-worker"
}
variable "master_disk_image" {
  description = "Disk image for reddit db"
  default     = "reddit-k8s-master"
}
variable "access_key" {}
variable "secret_key" {}
variable "yc_instance_app_count" {}

variable "public_key_path" {}
variable "private_key_path" {}
variable "subnet_id" {}
variable "reddit_worker_name" {}
variable "yc_instance_app_count" {}
variable "worker_disk_image" {
  description = "Disk image for reddit k8s worker"
  default     = "reddit-k8s-worker"
}
variable "master_ip" {}

variable "public_key_path" {}
variable "private_key_path" {}
variable "subnet_id" {}
variable "reddit_master_name" {}
variable "master_disk_image" {
  description = "Disk image for master node kubernetes"
  default     = "reddit-k8s-master"
}

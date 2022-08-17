output "external_ip_address_worker" {
  value = yandex_compute_instance.k8s_worker.*.network_interface.0.nat_ip_address
}

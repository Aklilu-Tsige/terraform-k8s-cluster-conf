output "master_public_ip" {
  value = module.compute.master_public_ip
}

output "worker_public_ips" {
  value = module.compute.worker_public_ips
}

output "private_key_path" {
  value = "${path.root}/keys/${var.environment}-k8s-key.pem"
}
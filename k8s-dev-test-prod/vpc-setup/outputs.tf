output "vpc_id" {
  value       = module.vpc.vpc_id
  description = "The ID of the created VPC"
}

output "public_subnets" {
  value       = module.vpc.public_subnets
  description = "IDs of the public subnets"
}

output "private_subnets" {
  value       = module.vpc.private_subnets
  description = "IDs of the private subnets"
}

output "master_node_public_ip" {
  value       = aws_instance.master_node.public_ip
  description = "Public IP of the master node instance"
}

output "worker_nodes_private_ips" {
  value       = aws_instance.worker_node[*].private_ip
  description = "Private IPs of the worker node instances"
}

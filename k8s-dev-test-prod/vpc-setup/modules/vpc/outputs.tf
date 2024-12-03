output "vpc_id" {
  value       = aws_vpc.main.id
  description = "The ID of the created VPC"
}

output "public_subnets" {
  value       = aws_subnet.public[*].id
  description = "IDs of the public subnets"
}

output "private_subnets" {
  value       = aws_subnet.private[*].id
  description = "IDs of the private subnets"
}

output "public_sg_id" {
  value       = aws_security_group.public_sg.id
  description = "The ID of the public security group"
}

output "private_sg_id" {
  value       = aws_security_group.private_sg.id
  description = "The ID of the private security group"
}

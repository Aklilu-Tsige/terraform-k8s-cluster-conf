variable "region" {
  description = "AWS region"
  default     = "eu-central-2"
}

variable "environment" {
  description = "Environment name"
  default     = "production"
}

variable "vpc_cidr" {
  description = "CIDR block for VPC"
  default     = "10.0.0.0/16"
}

variable "availability_zones" {
  description = "Availability zones"
  type        = list(string)
  default     = ["eu-central-2a", "eu-central-2b"]
}

variable "public_subnet_cidrs" {
  description = "CIDR blocks for public subnets"
  type        = list(string)
  default     = ["10.0.1.0/24", "10.0.2.0/24"]
}

variable "private_subnet_cidrs" {
  description = "CIDR blocks for private subnets"
  type        = list(string)
  default     = ["10.0.3.0/24", "10.0.4.0/24"]
}

variable "trusted_ips" {
  description = "List of trusted IP addresses for SSH access"
  type        = list(string)
  default     = ["0.0.0.0/0"]
}

variable "instance_type_master" {
  description = "Instance type for master node"
  default     = "t3.medium"
}

variable "instance_type_worker" {
  description = "Instance type for worker nodes"
  default     = "t3.medium"
}

variable "worker_count" {
  description = "Number of worker nodes"
  default     = 2
}
# VPC Configuration
variable "vpc_cidr" {
  description = "The CIDR block for the VPC"
  type        = string
  default     = "10.0.0.0/16"
}

variable "availability_zones" {
  description = "The list of availability zones to use"
  type        = list(string)
  default     = ["eu-central-2a", "eu-central-2b"]
}

variable "tags" {
  description = "Tags to apply to all resources"
  type        = map(string)
  default     = {
    Environment = "production"
    Project     = "k8s-cluster"
  }
}

# EC2 Instance Configuration
variable "ami_id" {
  description = "AMI ID for EC2 instances (must support 64-bit x86 architecture)"
  type        = string
  default     = "ami-08043a9b63e88457a" # Ubuntu 24.04 LTS x86_64
}

variable "instance_type" {
  description = "Instance type for EC2 instances (compatible with 64-bit x86 architecture)"
  type        = string
  default     = "t3.medium"
}

variable "worker_node_count" {
  description = "Number of worker nodes"
  type        = number
  default     = 2
}

variable "key_name" {
  description = "SSH key name to access the instances"
  type        = string
  default     = "k8-cluster" # Replace with your actual SSH key name
}
variable "architecture" {
  description = "Instance architecture"
  type        = string
  default     = "x86_64"
}


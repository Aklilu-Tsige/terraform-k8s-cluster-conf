variable "vpc_id" {}
variable "public_subnet_ids" {
  type = list(string)
}
variable "private_subnet_ids" {
  type = list(string)
}
variable "master_sg_id" {}
variable "worker_sg_id" {}
variable "instance_type_master" {}
variable "instance_type_worker" {}
variable "worker_count" {}
variable "environment" {}
variable "volume_size" {
  default = 20
}

variable "key_name" {
  description = "Name of the SSH key pair"
  type        = string
}
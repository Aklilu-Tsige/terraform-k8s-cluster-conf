# modules/security/variables.tf
variable "vpc_id" {}
variable "vpc_cidr" {}
variable "environment" {}
variable "trusted_ips" {
  type = list(string)
}
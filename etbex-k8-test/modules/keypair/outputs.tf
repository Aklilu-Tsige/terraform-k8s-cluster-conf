# modules/keypair/outputs.tf
output "key_name" {
  value = aws_key_pair.k8s_key.key_name
}
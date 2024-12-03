region               = "eu-central-2"
environment          = "production"
vpc_cidr             = "10.0.0.0/16"
trusted_ips          = ["0.0.0.0/0"]  # Restrict this to your IP in production
worker_count         = 2
instance_type_master = "t3.medium"
instance_type_worker = "t3.medium"
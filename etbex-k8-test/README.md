# AWS Kubernetes Cluster Infrastructure with Terraform

This repository provides a modular Terraform configuration for deploying a Kubernetes-ready infrastructure on AWS, including VPC, security groups, and EC2 instances.

## Infrastructure Overview

- **Region**: eu-central-2 (Zurich)
- **VPC**: Single VPC with public and private subnets
- **Availability Zones**: 2 AZs (eu-central-2a, eu-central-2b)
- **Kubernetes Nodes**: 1 master, 2 workers
- **Instance Types**: t3.medium (configurable)

### Network Architecture
```
VPC (10.0.0.0/16)
├── Public Subnets
│   ├── eu-central-2a (10.0.1.0/24)
│   └── eu-central-2b (10.0.2.0/24)
└── Private Subnets
    ├── eu-central-2a (10.0.3.0/24)
    └── eu-central-2b (10.0.4.0/24)
```

## Project Structure
```
.
├── main.tf                 # Main configuration
├── variables.tf            # Variable declarations
├── terraform.tfvars        # Variable values
├── outputs.tf             # Output declarations
├── keys/                  # Generated SSH keys
└── modules/
    ├── vpc/               # VPC configuration
    ├── security/          # Security groups
    ├── compute/           # EC2 instances
    └── keypair/           # SSH key management
```

## Prerequisites

- AWS CLI configured
- Terraform >= 1.0
- Git

## Quick Start

1. Clone the repository:
```bash
git clone <repository-url>
cd etbex-k8-test
```

2. Initialize Terraform:
```bash
terraform init
```

3. Update `terraform.tfvars` with your configuration:
```hcl
region               = "eu-central-2"
environment          = "production"
vpc_cidr             = "10.0.0.0/16"
trusted_ips          = ["YOUR_IP/32"]
worker_count         = 2
instance_type_master = "t3.medium"
instance_type_worker = "t3.medium"
```

4. Review and apply:
```bash
terraform plan
terraform apply
```

## Security Groups Configuration

### Master Node
- SSH (22)
- Kubernetes API (6443)
- etcd (2379-2380)
- Kubelet API (10250)
- Scheduler (10251)
- Controller Manager (10252)

### Worker Nodes
- SSH (22)
- Kubelet API (10250)
- NodePort Services (30000-32767)

## Accessing the Cluster

After deployment, SSH into the master node:
```bash
ssh -i keys/production-k8s-key.pem ubuntu@<master_public_ip>
```

## Module Details

### VPC Module
Creates networking infrastructure:
- VPC
- Public/Private Subnets
- Internet Gateway
- NAT Gateway
- Route Tables

### Security Module
Manages security groups:
- Master node security group
- Worker nodes security group
- Kubernetes-specific port configurations

### Compute Module
Handles EC2 instances:
- Master node
- Worker nodes
- Volume configurations

### Keypair Module
Manages SSH access:
- Generates new key pair
- Stores private key locally
- Configures AWS key pair

## Variables

| Name | Description | Default |
|------|-------------|---------|
| region | AWS Region | eu-central-2 |
| environment | Environment name | production |
| vpc_cidr | VPC CIDR block | 10.0.0.0/16 |
| worker_count | Number of worker nodes | 2 |
| instance_type_master | Master node instance type | t3.medium |
| instance_type_worker | Worker node instance type | t3.medium |

## Outputs

- Master node public IP
- Worker nodes public IPs
- Private key path

## Clean Up

To destroy all resources:
```bash
terraform destroy
```

## Infrastructure Validation

Before configuring Kubernetes, validate your infrastructure setup with these checks:

### 1. SSH Access Verification
```bash
# Access master node
ssh -i keys/production-k8s-key.pem ubuntu@<master_public_ip>

# Install necessary tools
sudo apt update
sudo apt install -y netcat-openbsd net-tools traceroute
```

### 2. Network Connectivity Tests
```bash
# Test ping to worker nodes
ping -c 4 <worker1_private_ip>
ping -c 4 <worker2_private_ip>

# Check network interfaces
ip addr show

# View routing table
ip route show
```

### 3. Kubernetes Port Validation
```bash
# Test master to worker connectivity
# Kubelet API (10250)
nc -zv <worker1_private_ip> 10250
nc -zv <worker2_private_ip> 10250

# Test NodePort range (30000-32767)
nc -zv <worker1_private_ip> 30000
nc -zv <worker2_private_ip> 30000
```

### 4. Worker Nodes SSH Access
```bash
# Copy key to master node
scp -i keys/production-k8s-key.pem keys/production-k8s-key.pem ubuntu@<master_public_ip>:~/.ssh/

# Set permissions
chmod 400 ~/.ssh/production-k8s-key.pem

# Access worker nodes
ssh -i ~/.ssh/production-k8s-key.pem ubuntu@<worker1_private_ip>
ssh -i ~/.ssh/production-k8s-key.pem ubuntu@<worker2_private_ip>
```

### 5. DNS and Internet Connectivity
```bash
# Test DNS resolution
nslookup google.com

# Test internet connectivity
curl -v https://www.google.com

# Check DNS configuration
cat /etc/resolv.conf
```

### 6. Security Group Verification
```bash
# Check master node ports
sudo netstat -plnt | grep -E '6443|2379|2380|10250|10251|10252'

# Check worker node ports
sudo netstat -plnt | grep -E '10250|30000'
```

### 7. Network Latency Check
```bash
# Test latency to workers
time ping -c 4 <worker1_private_ip>
time ping -c 4 <worker2_private_ip>
```

### 8. System Requirements Check
```bash
# Memory status
free -m

# Disk space
df -h

# CPU cores
nproc
lscpu

# Swap status
swapon --show
```

### Expected Results

#### Network Connectivity
- Ping responses: < 1ms latency
- SSH: Successful connections
- DNS: Proper resolution
- Internet: Accessible

#### System Requirements
- CPU: 2+ cores
- RAM: 2+ GB
- Storage: >20GB available
- Swap: Disabled

### Troubleshooting Common Issues

1. SSH Permission Denied
```bash
chmod 400 ~/.ssh/production-k8s-key.pem
```

2. Network Connectivity Issues
- Verify security group rules
- Check VPC routing tables
- Confirm subnet configurations

3. Port Access Problems
- Review security group inbound rules
- Check network ACLs
- Verify instance health status

4. System Requirement Issues
```bash
# Disable swap
sudo swapoff -a
sudo sed -i '/ swap / s/^\(.*\)$/#\1/g' /etc/fstab
```

Complete these validation steps before proceeding with Kubernetes installation to ensure a smooth cluster setup.

## Next Steps

1. Install Kubernetes components
2. Initialize the cluster
3. Configure networking (Calico/Flannel)
4. Join worker nodes

## Best Practices

1. Always use private subnets for worker nodes in production
2. Restrict SSH access to known IPs
3. Regularly update security group rules
4. Use proper IAM roles and policies
5. Enable VPC flow logs for network monitoring

## Support

For issues and feature requests, please open an issue in the repository.

## License

MIT License
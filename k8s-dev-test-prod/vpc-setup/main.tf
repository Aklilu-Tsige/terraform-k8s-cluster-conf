provider "aws" {
  region = "eu-central-2"
}

module "vpc" {
  source                = "./modules/vpc"
  vpc_cidr              = var.vpc_cidr
  availability_zones    = var.availability_zones
  public_subnet_count   = 2
  private_subnet_count  = 2
  tags                  = var.tags
}

# Master Node EC2 Instance
resource "aws_instance" "master_node" {
  ami           = var.ami_id
  instance_type = var.instance_type
  subnet_id     = module.vpc.public_subnets[0]
  key_name      = var.key_name
  security_groups = [module.vpc.public_sg_id]

  user_data = <<-EOF
    #!/bin/bash
    set -e

    echo "Step 1: Setting up containerd..."
    cat <<EOT > /etc/modules-load.d/containerd.conf
    overlay
    br_netfilter
    EOT

    modprobe overlay
    modprobe br_netfilter

    cat <<EOT > /etc/sysctl.d/99-kubernetes-cri.conf
    net.bridge.bridge-nf-call-iptables  = 1
    net.ipv4.ip_forward                 = 1
    net.bridge.bridge-nf-call-ip6tables = 1
    EOT

    sysctl --system

    apt-get update
    apt-get install -y containerd
    mkdir -p /etc/containerd
    containerd config default > /etc/containerd/config.toml
    sed -i 's/SystemdCgroup = false/SystemdCgroup = true/' /etc/containerd/config.toml
    systemctl restart containerd

    echo "Step 2: Kernel Parameter Configuration..."
    cat <<EOT > /etc/sysctl.d/k8s.conf
    net.bridge.bridge-nf-call-ip6tables = 1
    net.bridge.bridge-nf-call-iptables = 1
    EOT

    sysctl --system

    echo "Step 3: Configuring Kubernetes repository and installing kubeadm..."
    apt-get install -y apt-transport-https ca-certificates curl
    curl -fsSL https://pkgs.k8s.io/core:/stable:/v1.31/deb/Release.key | gpg --dearmor -o /etc/apt/keyrings/kubernetes-apt-keyring.gpg
    echo 'deb [signed-by=/etc/apt/keyrings/kubernetes-apt-keyring.gpg] https://pkgs.k8s.io/core:/stable:/v1.31/deb/ /' > /etc/apt/sources.list.d/kubernetes.list
    apt-get update
    apt-get install -y kubelet kubeadm kubectl
    apt-mark hold kubelet kubeadm kubectl

    echo "Step 4: Initializing Kubernetes cluster..."
    kubeadm init --pod-network-cidr=10.244.0.0/16 --kubernetes-version=1.31

    echo "Step 5: Configuring kubectl for the admin user..."
    mkdir -p $HOME/.kube
    cp -i /etc/kubernetes/admin.conf $HOME/.kube/config
    chown $(id -u):$(id -g) $HOME/.kube/config

    echo "Step 6: Deploying the Flannel network plugin..."
    kubectl apply -f https://raw.githubusercontent.com/coreos/flannel/master/Documentation/kube-flannel.yml
  EOF

  tags = merge(var.tags, { Name = "k8s-master-node" })
}

# Worker Node EC2 Instances
resource "aws_instance" "worker_node" {
  count         = var.worker_node_count
  ami           = var.ami_id
  instance_type = var.instance_type
  subnet_id     = element(module.vpc.private_subnets, count.index % length(module.vpc.private_subnets))
  key_name      = var.key_name
  security_groups = [module.vpc.private_sg_id]

  user_data = <<-EOF
    #!/bin/bash
    set -e

    echo "Step 1: Setting up containerd..."
    cat <<EOT > /etc/modules-load.d/containerd.conf
    overlay
    br_netfilter
    EOT

    modprobe overlay
    modprobe br_netfilter

    cat <<EOT > /etc/sysctl.d/99-kubernetes-cri.conf
    net.bridge.bridge-nf-call-iptables  = 1
    net.ipv4.ip_forward                 = 1
    net.bridge.bridge-nf-call-ip6tables = 1
    EOT

    sysctl --system

    apt-get update
    apt-get install -y containerd
    mkdir -p /etc/containerd
    containerd config default > /etc/containerd/config.toml
    sed -i 's/SystemdCgroup = false/SystemdCgroup = true/' /etc/containerd/config.toml
    systemctl restart containerd

    echo "Step 2: Kernel Parameter Configuration..."
    cat <<EOT > /etc/sysctl.d/k8s.conf
    net.bridge.bridge-nf-call-ip6tables = 1
    net.bridge.bridge-nf-call-iptables = 1
    EOT

    sysctl --system

    echo "Step 3: Configuring Kubernetes repository and installing kubeadm..."
    apt-get install -y apt-transport-https ca-certificates curl
    curl -fsSL https://pkgs.k8s.io/core:/stable:/v1.31/deb/Release.key | gpg --dearmor -o /etc/apt/keyrings/kubernetes-apt-keyring.gpg
    echo 'deb [signed-by=/etc/apt/keyrings/kubernetes-apt-keyring.gpg] https://pkgs.k8s.io/core:/stable:/v1.31/deb/ /' > /etc/apt/sources.list.d/kubernetes.list
    apt-get update
    apt-get install -y kubelet kubeadm
    apt-mark hold kubelet kubeadm

    echo "Worker node setup complete. Please join this node to the cluster using kubeadm join command."
  EOF

  tags = merge(var.tags, { Name = "k8s-worker-node-${count.index + 1}" })
}

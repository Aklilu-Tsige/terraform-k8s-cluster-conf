data "aws_ami" "ubuntu" {
  most_recent = true

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-jammy-22.04-amd64-server-*"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }

  owners = ["099720109477"]
}

resource "aws_instance" "k8s_master" {
  ami           = data.aws_ami.ubuntu.id
  instance_type = var.instance_type_master
  subnet_id     = var.public_subnet_ids[0]
  key_name      = var.key_name

  vpc_security_group_ids = [var.master_sg_id]

  root_block_device {
    volume_size = var.volume_size
  }

  tags = {
    Name        = "${var.environment}-kubernetes-master"
    Environment = var.environment
  }
}

resource "aws_instance" "k8s_worker" {
  count         = var.worker_count
  ami           = data.aws_ami.ubuntu.id
  instance_type = var.instance_type_worker
  subnet_id     = var.public_subnet_ids[count.index % length(var.public_subnet_ids)]
  key_name      = var.key_name

  vpc_security_group_ids = [var.worker_sg_id]

  root_block_device {
    volume_size = var.volume_size
  }

  tags = {
    Name        = "${var.environment}-kubernetes-worker-${count.index + 1}"
    Environment = var.environment
  }
}
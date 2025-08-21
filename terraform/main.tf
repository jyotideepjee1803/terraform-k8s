provider "aws" {
  region = var.region
}

# Networking
resource "aws_vpc" "k8s" {
  cidr_block = "10.0.0.0/16"
  tags = merge(var.tags, {Name = "k8s-vps"})
}

resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.k8s.id
}

resource "aws_subnet" "public" {
  vpc_id = aws_vpc.k8s.id
  cidr_block = "10.0.1.0/24"
  map_public_ip_on_launch = true
  availability_zone = "${var.region}a"
}

resource "aws_route_table" "rt" {
  vpc_id = aws_vpc.k8s.id
  route{
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw.id
  }
}

resource "aws_route_table_association" "rtassoc" {
  subnet_id = aws_subnet.public.id
  route_table_id = aws_route_table.rt.id
}

# Security groups
resource "aws_security_group" "k8s" {
  name = "k8s-sg"
  description = "K8s cluster security group"
  vpc_id = aws_vpc.k8s.id

  ingress {
      description = "SSH"
      from_port = 22
      to_port = 22
      protocol = "tcp"
      cidr_blocks = [var.ssh_ingress_cidr]
    }

  ingress  {
      from_port = 6443
      to_port = 6443
      protocol = "tcp"
      cidr_blocks = [ "0.0.0.0/0" ]
    }

  ingress {
        from_port = 30000
        to_port = 32767
        protocol = "tcp"
        cidr_blocks = [ "0.0.0.0/0" ]
      }

  ingress {
        from_port = 30000
        to_port = 32767
        protocol = "udp"
        cidr_blocks = [ "0.0.0.0/0" ]
      }

  ingress {
        from_port = 0
        to_port = 0
        protocol = "-1"
        cidr_blocks = [ aws_vpc.k8s.cidr_block ]
      }

  egress {
    from_port = 0
    to_port = 0
    protocol = "-1"
    cidr_blocks = [ "0.0.0.0/0" ]
  }

  tags = var.tags
}

data "aws_ami" "ubuntu" {
  owners = ["099720109477"]
  most_recent = true
  filter {
    name = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-jammy-22.04-amd64-server-*"]
  }
  filter {
    name = "virtualization-type"
    values = [ "hvm" ]
  }
}

resource "aws_instance" "master" {
  count = var.master_count
  ami = data.aws_ami.ubuntu.id
  instance_type = var.instance_type
  subnet_id = aws_subnet.public.id
  key_name = var.key_name
  vpc_security_group_ids = [aws_security_group.k8s.id]
  tags = merge(var.tags, {Name = "k8s-master-${count.index}"})
}

resource "aws_instance" "worker" {
  count = var.worker_count
  ami = data.aws_ami.ubuntu.id
  instance_type = var.instance_type
  subnet_id = aws_subnet.public.id
  key_name = var.key_name
  vpc_security_group_ids = [aws_security_group.k8s.id]
  tags = merge(var.tags, {Name = "k8s-master-${count.index}"})
}

locals {
  masters = [for i in aws_instance.master : i.public_ip]
  workers = [for i in aws_instance.worker : i.public_ip]
}

resource "local_file" "inventory" {
  filename = "${path.module}/../ansible/inventories/hosts.ini"
  content = templatefile("${path.module}/inventory.tftpl",{
    masters = local.masters
    workers = local.workers
  })
}


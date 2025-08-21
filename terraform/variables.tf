variable "region"{
    default = "ap-south-1"
}

variable "key_name" {
  description = "Existing EC2 key pair name"
}

variable "master_count" {
  default = 1
}

variable "worker_count" {
  default = 2
}

variable "instance_type" {
  default = "t3.medium"
}

variable "ssh_ingress_cidr" {
  default = "0.0.0.0/0"
}

variable "tags" {
  type = map(string)
  default = {
        Project = "kubeadm-crio-cluster"
  }
}
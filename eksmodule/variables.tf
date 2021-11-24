variable "vpc_cidr" {
  default = "10.0.0.0/16"
}

variable "public_subnet_cidrs" {
  default = [
    "10.0.110.0/24",
    "10.0.120.0/24",
    "10.0.130.0/24"
  ]
}

variable "private_subnet_cidrs" {
  default = [
    "10.0.140.0/24",
    "10.0.150.0/24",
    "10.0.160.0/24"
  ]
}

variable "eks_cluster_name" {
  default = "eks-ubuntu-cluster"
}

variable "eks_cluster_version" {
  default = "1.18"
}

variable "instance_type" {
  default = "t3a.medium"
}

variable "instance_ami" {
  default = "ami-0619517a5212182ee"
}

variable "desired_capacity" {
  default = 6
}

variable "min_size" {
  default = 5
}

variable "max_size" {
  default = 10
}

variable "on_demand_base_capacity" {
  default = 1
}

variable "on_demand_percentage_above_base_capacity" {
  default = 20
}

variable "device_name" {
  default = "/dev/sda1"
}

variable "ebs_volume_size" {
  default = 20
}

variable "ebs_volume_type" {
  default = "gp2"
}
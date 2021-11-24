variable "project" {
  description = "Name of project to tag all deployed resources"
  type        = string
  default     = "ubuntu-eks-cluster"
}

variable "vpc_cidr" {
  description = "The CIDR block for the VPC"
  type        = string
}

variable "public_subnet_cidrs" {
  description = "A list of public subnets to place the EKS cluster and workers within."
  type        = list(string)
}

variable "private_subnet_cidrs" {
  description = "A list of private subnets for place RDS."
  type        = list(string)
}

variable "eks_cluster_name" {
  description = "(Required) The name of the Amazon EKS cluster."
  type        = string
}

variable "eks_cluster_version" {
  description = "Kubernetes minor version to use for the EKS cluster (for example 1.21)."
  type        = string
}

variable "instance_type" {
  type        = string
  description = "(Required) The EC2 instance type to use for the worker nodes."
}

variable "instance_ami" {
  type        = string
  description = "EKS optimised ami"
}

variable "desired_capacity" {
  type        = number
  description = "(Required) The desired number of nodes to create in the node group."
}

variable "min_size" {
  type        = number
  description = "(Required) The minimum number of nodes to create in the node group."
}

variable "max_size" {
  type        = number
  description = "(Required) The maximum number of nodes to create in the node group."
}

variable "name_prefix" {
  type        = string
  description = "(Optional) Creates a unique name beginning with the specified prefix. Conflicts with `name`."
  default     = "node-group"
}

variable "tags" {
  type        = map(any)
  description = "(Optional) Tags to apply to all tag-able resources."
  default     = {}
}

variable "node_labels" {
  type        = map(any)
  description = "(Optional) Kubernetes labels to apply to all nodes in the node group."
  default     = {}
}

variable "device_name" {
  type        = string
  description = "(Optional) The name of the device to mount."
  default     = "/dev/sda1"
}

variable "ebs_volume_size" {
  type        = number
  description = "(Optional) The EBS volume size for a worker node. By default, the module uses the setting from the selected AMI."
}

variable "ebs_volume_type" {
  type        = string
  description = "(Optional) The EBS volume type for a worker node. By default, the module uses the setting from the selected AMI."
}

variable "on_demand_base_capacity" {
  description = "Absolute minimum amount of desired capacity that must be fulfilled by on-demand instances. Default: 0."
  type        = number
}

variable "on_demand_percentage_above_base_capacity" {
  description = "(Optional) Percentage split between on-demand and Spot instances above the base on-demand capacity. Default: 100."
  type        = number
}

resource "random_id" "name_suffix" {
  byte_length = 3
}

locals {
  node_group_name = coalesce("${var.name_prefix}-${random_id.name_suffix.hex}")
}
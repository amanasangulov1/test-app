data "aws_availability_zones" "available" {}

#VPC

resource "aws_vpc" "eks_vpc" {
  cidr_block = var.vpc_cidr
  tags = {
    Name                            = "${var.project} - EKS-VPC"
    Terraform                       = "true"
    "kubernetes.io/cluster/eks-lab" = "shared"
  }
}

#IGW

resource "aws_internet_gateway" "eks_igw" {
  vpc_id = aws_vpc.eks_vpc.id
  tags = {
    Name                            = "${var.project} - EKS-IGW"
    Terraform                       = "true"
    "kubernetes.io/cluster/eks-lab" = "shared"
  }
}


#PUBLIC SUBNETS

resource "aws_subnet" "eks_public_subnet" {
  count                   = length(var.public_subnet_cidrs)
  vpc_id                  = aws_vpc.eks_vpc.id
  cidr_block              = element(var.public_subnet_cidrs, count.index)
  availability_zone       = data.aws_availability_zones.available.names[count.index]
  map_public_ip_on_launch = true
  tags = {
    Name                            = "${var.project} - Public_subnet - ${count.index + 1}"
    Terraform                       = "true"
    "kubernetes.io/cluster/eks-lab" = "shared"
  }
}

#ROUTE TABLE

resource "aws_route_table" "eks_public_rt" {
  vpc_id = aws_vpc.eks_vpc.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.eks_igw.id
  }
  tags = {
    Name                            = "${var.project} - Public Route Table"
    Terraform                       = "true"
    "kubernetes.io/cluster/eks-lab" = "shared"
  }
}

#ROUTE TABLE ASSOCIATION

resource "aws_route_table_association" "eks_rt" {
  count          = length(aws_subnet.eks_public_subnet[*].id)
  route_table_id = aws_route_table.eks_public_rt.id
  subnet_id      = element(aws_subnet.eks_public_subnet[*].id, count.index)
}

#PRIVITE SUBNETS

resource "aws_subnet" "eks_private_subnet" {
  count             = length(var.private_subnet_cidrs)
  vpc_id            = aws_vpc.eks_vpc.id
  cidr_block        = element(var.private_subnet_cidrs, count.index)
  availability_zone = data.aws_availability_zones.available.names[count.index]

  tags = {
    Name = "${var.project} - Private_subnet- ${count.index + 1}"
  }
}
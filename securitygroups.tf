resource "aws_security_group" "cluster" {
  name        = "EKS-cluster"
  description = "Cluster communication with worker nodes"
  vpc_id      = aws_vpc.eks_vpc.id

  egress {
    description      = "Allow cluster egress access to the Internet."
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = []
    prefix_list_ids  = []
    self             = false
  }

  tags = {
    Name = "terraform-eks-sg-cluster"
  }
}

resource "aws_security_group_rule" "cluster-ingress-workstation-https" {
  description       = "Allow pods to communicate with the EKS cluster API."
  type              = "ingress"
  from_port         = 443
  to_port           = 443
  protocol          = "tcp"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = aws_security_group.cluster.id
}

resource "aws_security_group" "worker-nodes" {
  name        = "worker-nodes"
  description = "Workers communication with each other"
  vpc_id      = aws_vpc.eks_vpc.id

  egress {
    description      = "Allow nodes all egress to the Internet."
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
    security_groups  = []
    ipv6_cidr_blocks = []
    prefix_list_ids  = []
    self             = false
  }

  tags = {
    Name = "terraform-eks-sg-worker"
  }
}

resource "aws_security_group_rule" "workers-to-communicate" {
  description       = "Allow node to communicate with each other."
  type              = "ingress"
  from_port         = 80
  to_port           = 80
  protocol          = "tcp"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = aws_security_group.worker-nodes.id
}

resource "aws_security_group_rule" "workers-to-cluster" {
  description              = "Allow pods running extension API servers on port 443 to receive communication from cluster"
  type                     = "ingress"
  from_port                = 443
  to_port                  = 443
  protocol                 = "tcp"
  source_security_group_id = aws_security_group.cluster.id
  security_group_id        = aws_security_group.worker-nodes.id
}
#
resource "aws_security_group_rule" "workers-ssh" {
  description              = "Allow pods ssh"
  type                     = "ingress"
  from_port                = 22
  to_port                  = 22
  protocol                 = "tcp"
  security_group_id        = aws_security_group.worker-nodes.id
  source_security_group_id = aws_security_group.worker-nodes.id
}
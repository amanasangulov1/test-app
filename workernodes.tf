data "aws_eks_cluster" "eks_cluster" {
  name = aws_eks_cluster.selected.name
}

data "aws_ec2_instance_type" "selected" {
  instance_type = var.instance_type
}

resource "aws_launch_template" "eks_self_managed_nodes" {
  name          = var.eks_cluster_name
  instance_type = var.instance_type
  image_id      = var.instance_ami


  vpc_security_group_ids = [aws_security_group.cluster.id, aws_security_group.worker-nodes.id]

  iam_instance_profile {
    arn = aws_iam_instance_profile.eks_self_managed_node_group.arn
  }
  block_device_mappings {
    device_name = var.device_name

    ebs {
      volume_size = var.ebs_volume_size
      volume_type = var.ebs_volume_type
    }
  }
  user_data = base64encode(templatefile("${path.module}/user_data.sh", {
    cluster_name = var.eks_cluster_name
    node_labels  = var.node_labels
  }))

}

resource "aws_autoscaling_group" "eks_self_managed_node_group" {
  name             = var.eks_cluster_name
  max_size         = var.max_size
  min_size         = var.min_size
  desired_capacity = var.desired_capacity

  vpc_zone_identifier = [aws_subnet.eks_public_subnet[0].id, aws_subnet.eks_public_subnet[1].id, aws_subnet.eks_public_subnet[2].id, ]

  mixed_instances_policy {
    instances_distribution {
      on_demand_base_capacity                  = var.on_demand_base_capacity
      on_demand_percentage_above_base_capacity = var.on_demand_percentage_above_base_capacity
      spot_allocation_strategy                 = "lowest-price"
    }
    launch_template {
      launch_template_specification {
        launch_template_id = aws_launch_template.eks_self_managed_nodes.id
      }
    }
  }

  tags = concat(
    [
      for tag, value in var.tags : {
        key                 = tag
        value               = value
        propagate_at_launch = true
      }
    ],
    [
      {
        key                 = "Name"
        value               = var.eks_cluster_name
        propagate_at_launch = true
      },
      {
        key                 = "kubernetes.io/cluster/${var.eks_cluster_name}"
        value               = "owned"
        propagate_at_launch = true
      },
    ]
  )
  depends_on = [
    aws_iam_role_policy_attachment.worker_amazonEKSWorkerNodePolicy,
    aws_iam_role_policy_attachment.worker_AmazonEKS_CNI_Policy,
    aws_iam_role_policy_attachment.worker_amazonEC2ContainerRegistryReadOnly
  ]
}
resource "aws_iam_role" "marefiya_eks_iam_role" {
  name = "marefiya_eks_iam_role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
        {
            Action = "sts:AssumeRole"
            Effect = "Allow"
            Principal = {
                Service = "eks.amazonaws.com"
            }
        }
    ]
  })
}
data "aws_iam_policy" "marefiya_iam_policy" {
  name = var.marefiya_iam_policy_name
}
resource "aws_iam_role_policy_attachment" "marefiya_eks_iam_role_attachment" {
  role = aws_iam_role.marefiya_eks_iam_role.name
 policy_arn = data.aws_iam_policy.marefiya_iam_policy.arn
}

resource "aws_eks_cluster" "marefiya_eks_cluster" {
  name = var.marefiya_cluster_name
  access_config {
    authentication_mode = "API"
    bootstrap_cluster_creator_admin_permissions = true
  }
  role_arn = aws_iam_role.marefiya_eks_iam_role.arn
  version = var.kubernates_version
  bootstrap_self_managed_addons = false
 vpc_config {
   endpoint_private_access = true
   endpoint_public_access = true
   subnet_ids = var.marefiya_private_subnet
 }
}
resource "aws_iam_role" "marefiya_worker_node_iam_role" {
  name = "marefiya_worker_node_iam_role"
  assume_role_policy = jsonencode({
    Version  = "2012-10-17"
    Statement = [
        {
            Action = [
                "sts:AssumeRole"
            ]
            Effect = "Allow"
            Principal = {
                Service = "ec2.amazonaws.com"
            }
        }
    ]
  })
}

data "aws_iam_policy" "marefiya_worker_node_iam_policy" {
    for_each = var.marefiya_worker_node_iam_policy
    name = each.value

}
resource "aws_iam_role_policy_attachment" "marefiya_worker_node_iam_policy_attachment" {
    for_each = var.marefiya_worker_node_iam_policy
   policy_arn  = data.aws_iam_policy.marefiya_worker_node_iam_policy[each.key].arn
  role = aws_iam_role.marefiya_worker_node_iam_role.name
}
resource "aws_eks_node_group" "marefiya_eks_node_group" {
  cluster_name = aws_eks_cluster.marefiya_eks_cluster.name
  node_group_name = "marefiya_worker_node_group"
  node_role_arn = aws_iam_role.marefiya_worker_node_iam_role.arn
  subnet_ids = var.marefiya_private_subnet
  depends_on = [ aws_iam_role_policy_attachment.marefiya_worker_node_iam_policy_attachment,aws_eks_addon.marefiya_eks_pod_cni]

  scaling_config {
    desired_size = var.scale_config_worker_nodes.desired_size
    max_size = var.scale_config_worker_nodes.max_size
    min_size = var.scale_config_worker_nodes.min_size
  }
  update_config {
    max_unavailable = var.scale_config_worker_nodes.max_unavailable
  }
  disk_size = var.scale_config_worker_nodes.disk_size
  capacity_type = var.scale_config_worker_nodes.capacity_type
}

resource "aws_security_group" "marefiya_alb_security_group" {
  name = "marefiya_alb_security_group"
  vpc_id = var.marefiya_vpc
}
resource "aws_vpc_security_group_ingress_rule" "marefiya_alb_ingress_rule" {
  security_group_id = aws_security_group.marefiya_alb_security_group.id
  cidr_ipv4 = var.alb_ingress.cidr_block
  from_port = var.alb_ingress.from_alb_port
  to_port = var.alb_ingress.to_alb_port
  ip_protocol = var.alb_ingress.alb_ip_protocol
}
//=======Finalize the security group for ALB and worker nodes
resource "aws_vpc_security_group_egress_rule" "marefiya_alb_egress_rule" {
 security_group_id = aws_security_group.marefiya_alb_security_group.id
 cidr_ipv4 = "0.0.0.0/0"
 from_port = -1
 to_port = -1
 ip_protocol = -1
}
resource "aws_security_group" "marefiya_worker_node_security_group" {
  name = "marefiya_worker_node_security_group"
  vpc_id = var.marefiya_vpc
}
resource "aws_vpc_security_group_ingress_rule" "marefiya_worker_node_ingress_security_group" {
  security_group_id = aws_security_group.marefiya_worker_node_security_group.id
  referenced_security_group_id = aws_security_group.marefiya_alb_security_group.id
  from_port = var.alb_ingress.from_alb_port
  to_port = var.alb_ingress.to_alb_port
  ip_protocol = var.alb_ingress.alb_ip_protocol
}
resource "aws_vpc_security_group_egress_rule" "marefiya_worker_node_egress_security_group" {
  security_group_id = aws_security_group.marefiya_worker_node_security_group.id
  cidr_ipv4 = "0.0.0.0/0"
  from_port = -1
  to_port = -1
  ip_protocol = -1
}
//----AWS_loadbalancer_controller IAM Role
resource "aws_iam_role" "aws_lb_controller_role" {
  name = "AWS_LoadBalancer_controller_role"
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = [
        "sts:AssumeRole",
         "sts:TagSession"
    ]
        Effect = "Allow"
        Principal = {
          Service = "pods.eks.amazonaws.com"
        }
      }
    ]
  })
}
resource "aws_iam_policy" "aws_lb_controller_policy" {
name = "aws_lb_controller_policy"
policy = file("${path.module}/iam_policy.json")
}
resource "aws_iam_role_policy_attachment" "aws_lb_controller_policy_attachment" {
  policy_arn = aws_iam_policy.aws_lb_controller_policy.arn
  role = aws_iam_role.aws_lb_controller_role.name
}
resource "aws_eks_pod_identity_association" "marefiya_eks_pod_identity" {
  cluster_name = aws_eks_cluster.marefiya_eks_cluster.name
  namespace = "kube-system"
  service_account = "aws-load-balancer-controller"
  role_arn = aws_iam_role.aws_lb_controller_role.arn
  disable_session_tags = "true"
}

resource "aws_eks_addon" "marefiya_eks_pod_identity_agent" {
  cluster_name = var.marefiya_cluster_name
  addon_name = "eks-pod-identity-agent"
  resolve_conflicts_on_update = "PRESERVE"
}
//-----pod networking-----
resource "aws_eks_addon" "marefiya_eks_pod_cni" {
  cluster_name = var.marefiya_cluster_name
  addon_name = "vpc-cni"
  resolve_conflicts_on_create = "OVERWRITE"
  resolve_conflicts_on_update = "PRESERVE"
}
//----------ip routing
resource "aws_eks_addon" "marefiya_eks_pod_kube_proxy" {
  cluster_name = var.marefiya_cluster_name
  addon_name = "kube-proxy"
  resolve_conflicts_on_create = "OVERWRITE"
  resolve_conflicts_on_update = "PRESERVE"
}
resource "aws_eks_addon" "marefiya_eks_pod_core_dns" {
  cluster_name = var.marefiya_cluster_name
  addon_name = "coredns"
  resolve_conflicts_on_create = "OVERWRITE"
  depends_on = [
    aws_eks_node_group.marefiya_eks_node_group
  ]
}

module "Networking" {
  source                   = "./modules/Networking"
  marefiya_vpc             = var.marefiya_vpc
  Environment              = var.Environment
  Project_name             = var.Project_name
  region                   = var.region
  marefiya_public_subnet   = var.marefiya_public_subnet
  marefiya_private_subnet  = var.marefiya_private_subnet
  route_cidr_block         = var.route_cidr_block
  private_route_cidr_block = var.private_route_cidr_block
}
module "Compute" {
  source                          = "./modules/Compute"
  marefiya_vpc                    = module.Networking.marefiya_vpc
  marefiya_private_subnet         = module.Networking.marefiya_private_subnet
  marefiya_cluster_name           = var.marefiya_cluster_name
  marefiya_iam_policy_name        = var.marefiya_iam_policy_name
  kubernates_version              = var.kubernates_version
  marefiya_worker_node_iam_policy = var.marefiya_worker_node_iam_policy
  scale_config_worker_nodes       = var.scale_config_worker_nodes
  aws_lb_controller_policy        = var.aws_lb_controller_policy
  alb_ingress                     = var.alb_ingress
}
resource "helm_release" "marefiya_lb_controller" {
  name       = "aws-loadbalancer-controller"
  repository = "https://aws.github.io/eks-charts"
  chart      = "aws-load-balancer-controller"
  namespace  = "kube-system"
  depends_on = [module.Compute.marefiya_eks_pod_identity_agent,
    module.Compute.marefiya_eks_node_group,
  module.Compute.marefiya_eks_cluster]
  set = [{
    name  = "clusterName"
    value = var.marefiya_cluster_name
    },

    {
      name  = "serviceAccount.create"
      value = "true"
    },

    {
      name  = "serviceAccount.name"
      value = "aws-load-balancer-controller"
    }
  ]
}


provider "aws" {
  region = var.region
  default_tags {
    tags = {
      Enviroment = var.Environment
      Project    = var.Project_name
    }
  }
}

provider "helm" {
  kubernetes = {
    host                   = module.Compute.eks_cluster_endpoint
    cluster_ca_certificate = base64decode(module.Compute.eks_cluster_certificate)
    exec = {
      api_version = "client.authentication.k8s.io/v1beta1"
      args        = ["eks", "get-token", "--cluster-name", var.marefiya_cluster_name, var.region]
      command     = "aws"
    }
  }
}



variable "region" {
  type        = string
  description = "This defines the configured region"
}
variable "Environment" {
  type        = string
  description = "This defines the Evironment configuration"
}
variable "Project_name" {
  type        = string
  description = "This defines the Project name"
}
variable "marefiya_vpc" {
  type        = string
  description = "This defines the Environment to be used."
}
variable "marefiya_public_subnet" {
  type = map(object({
    cidr_block        = string
    availability_zone = string
  }))
  description = "public subnet on az1"
}

variable "marefiya_private_subnet" {
  type = map(object({
    cidr_block        = string
    availability_zone = string
  }))
  description = "private subnet"
}

# variable "marefiya_public_subnet_ppd" {
#   type = map(object({
#     cidr_block        = string
#     availability_zone = string
#   }))
# }

# variable "" {
#   type = map(object({
#     cidr_block        = string
#     availability_zone = string
#   }))
# }
# variable "marefiya_public_subnet_prod" {
#   type = map(object({
#     cidr_block        = string
#     availability_zone = string
#   }))
# }
# variable "marefiya_private_subnet_prod" {
#   type = map(object({
#     cidr_block        = string
#     availability_zone = string
#   }))
# }

variable "route_cidr_block" {
  type        = string
  description = "public route cidr block"
}
variable "private_route_cidr_block" {
  type        = string
  description = "private route table cidr block"
}
variable "marefiya_cluster_name" {
  type = string
}
variable "kubernates_version" {
  type = string
}
variable "marefiya_worker_node_iam_policy" {
  type = map(string)
}
variable "marefiya_iam_policy_name" {
  type = string
}
variable "scale_config_worker_nodes" {
  type = map(string)
}
variable "aws_lb_controller_policy" {
  type = string
}
variable "alb_ingress" {
  type = map(string)
}
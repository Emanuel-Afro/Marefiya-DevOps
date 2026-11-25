variable "marefiya_vpc" {
 type = string
}
variable "marefiya_private_subnet" {
  type = list(string)
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
variable "alb_ingress" {
  type = map(string)
}
variable "aws_lb_controller_policy" {
  type = string
}
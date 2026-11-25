variable "region" {
  type = string
  description = "This defines the configured region"
}
variable "Environment" {
  type = string
  description = "This defines the Evironment configuration"
}
variable "Project_name" {
  type = string
  description = "This defines the Project name"
}
variable "marefiya_vpc" {
  type = string
  description = "This defines the Environment to be used."
}
variable "marefiya_public_subnet" {
  type = map(object({
    cidr_block = string
    availability_zone = string
  }))
  description = "public subnet on az"
}
variable "marefiya_private_subnet" {
    type = map(object({
    cidr_block = string
    availability_zone = string
  }))
  description = "private subnet"
}
# variable "availability_zone" {
#   type = string
#   description = "marefiya availability zone"
# }
variable "route_cidr_block" {
  type = string
  description = "public route cidr block"
}
variable "private_route_cidr_block" {
  type = string
  description = "private route cidr block"
}
//----------PPD config------------------------
# variable "marefiya_public_subnet_ppd" {
#   type = map(object({
#     cidr_block = string
#     availability_zone = string
#   }))
# }

# variable "marefiya_private_subnet_ppd" {
#   type = map(object({
#     cidr_block = string
#     availability_zone =string
#   }))
# }
//-----------PROD config-------------------
# variable "marefiya_public_subnet_prod" {
#   type = map(object({
#     cidr_block = string
#     availability_zone = string
#   }))
# }
# variable "marefiya_private_subnet_prod" {
#   type = map(object({
#     cidr_block = string
#     availability_zone = string
#   }))
# }
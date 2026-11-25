output "marefiya_vpc" {
 value = aws_vpc.marefiya_vpc.id
 description = "output for VPC_id"
}
output "marefiya_private_subnet" {
  value = [for subnet in aws_subnet.marefiya_private_subnet : subnet.id]
  description = "output for private subnet"
}


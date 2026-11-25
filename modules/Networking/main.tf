resource "aws_vpc" "marefiya_vpc" {
  cidr_block = var.marefiya_vpc
  region = var.region
  enable_dns_hostnames = true
  enable_dns_support = true
}
resource "aws_internet_gateway" "marefiya_igw" {
  vpc_id = aws_vpc.marefiya_vpc.id
  region = var.region
}
resource "aws_subnet" "marefiya_public_subnet" {
  for_each = var.marefiya_public_subnet
  vpc_id = aws_vpc.marefiya_vpc.id
  cidr_block = each.value.cidr_block
  availability_zone = each.value.availability_zone
}
resource "aws_subnet" "marefiya_private_subnet" {
  for_each = var.marefiya_private_subnet
  vpc_id = aws_vpc.marefiya_vpc.id
  cidr_block = each.value.cidr_block
  availability_zone = each.value.availability_zone
}
resource "aws_eip" "marefiya_eip" {
  domain = "vpc"
}
resource "aws_nat_gateway" "marefiya_nat_gateway" {
  allocation_id = aws_eip.marefiya_eip.id
  subnet_id = aws_subnet.marefiya_public_subnet[element(keys(var.marefiya_public_subnet), 0)].id
  depends_on = [ aws_internet_gateway.marefiya_igw ]
  tags = {
    Name = "Marefiya-Nat_gw"
  }
}

resource "aws_route_table" "marefiya_public_route_table" {
  vpc_id = aws_vpc.marefiya_vpc.id
  route {
    cidr_block = var.route_cidr_block
    gateway_id = aws_internet_gateway.marefiya_igw.id
  }
}
resource "aws_route_table" "marefiya_private_route_table" {
  vpc_id = aws_vpc.marefiya_vpc.id
  route {
    cidr_block = var.private_route_cidr_block
    nat_gateway_id = aws_nat_gateway.marefiya_nat_gateway.id
  }
}
resource "aws_route_table_association" "marefiya_public_route_table_association" {
  for_each = var.marefiya_public_subnet
  route_table_id =  aws_route_table.marefiya_public_route_table.id
  subnet_id = aws_subnet.marefiya_public_subnet[each.key].id
}
resource "aws_route_table_association" "marefiya_private_route_table_association" {
  for_each = var.marefiya_private_subnet
  route_table_id = aws_route_table.marefiya_private_route_table.id
  subnet_id = aws_subnet.marefiya_private_subnet[each.key].id
}

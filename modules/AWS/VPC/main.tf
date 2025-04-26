locals {
  az_count             = length(data.aws_availability_zones.available.names)
  public_subnet_count  = min(var.public_subnet_count, local.az_count)
  private_subnet_count = min(var.private_subnet_count, local.az_count) # Use private_subnet_count variable
  public_subnet_cidrs  = [for i in range(local.public_subnet_count) : cidrsubnet(var.vpc_cidr, 8, i)]
  private_subnet_cidrs = [for i in range(local.private_subnet_count) : cidrsubnet(var.vpc_cidr, 8, i + local.public_subnet_count)]
}

resource "aws_vpc" "vpc1" {
  cidr_block           = var.vpc_cidr
  enable_dns_support   = true
  enable_dns_hostnames = true

  tags = {
    Name = "VPC-${var.unique_suffix}"
  }
}

data "aws_availability_zones" "available" {}

resource "aws_internet_gateway" "igw1" {
  vpc_id = aws_vpc.vpc1.id

  tags = {
    Name = "InternetGateway-${var.unique_suffix}"
  }
}

resource "aws_subnet" "public_subnet" {
  count                   = local.public_subnet_count
  vpc_id                  = aws_vpc.vpc1.id
  cidr_block              = local.public_subnet_cidrs[count.index]
  availability_zone       = element(data.aws_availability_zones.available.names, count.index)
  map_public_ip_on_launch = true

  tags = {
    Name = "PublicSubnet-${count.index + 1}-${var.unique_suffix}"
  }
}

resource "aws_subnet" "private_subnet" {
  count             = local.private_subnet_count
  vpc_id            = aws_vpc.vpc1.id
  cidr_block        = local.private_subnet_cidrs[count.index]
  availability_zone = element(data.aws_availability_zones.available.names, count.index)

  tags = {
    Name = "PrivateSubnet-${count.index + 1}-${var.unique_suffix}"
  }
}

resource "aws_route_table" "public_route_table" {
  vpc_id = aws_vpc.vpc1.id

  route {
    cidr_block = var.igw_cidr
    gateway_id = aws_internet_gateway.igw1.id
  }

  tags = {
    Name = "PublicRouteTable-${var.unique_suffix}"
  }
}

resource "aws_route_table_association" "public_subnet_association" {
  count          = local.public_subnet_count
  subnet_id      = aws_subnet.public_subnet[count.index].id
  route_table_id = aws_route_table.public_route_table.id
}

resource "aws_route_table" "private_route_table" {
  vpc_id = aws_vpc.vpc1.id

  tags = {
    Name = "PrivateRouteTable-${var.unique_suffix}"
  }
}

resource "aws_route_table_association" "private_subnet_association" {
  count          = local.private_subnet_count
  subnet_id      = aws_subnet.private_subnet[count.index].id
  route_table_id = aws_route_table.private_route_table.id
}

resource "aws_db_subnet_group" "rds_subnet_group" {
  name       = "rds-subnet-group"
  subnet_ids = aws_subnet.private_subnet[*].id
  tags = {
    Name = "RDSSubnetGroup-${var.unique_suffix}"
  }
}

resource "aws_eip" "nat_eip" {
  vpc = true
}

resource "aws_nat_gateway" "nat_gateway" {
  allocation_id = aws_eip.nat_eip.id
  subnet_id     = aws_subnet.public_subnet[0].id

  tags = {
    Name = "NATGateway-${var.unique_suffix}"
  }
}

resource "aws_route" "private_subnet_nat_route" {
  route_table_id         = aws_route_table.private_route_table.id
  destination_cidr_block = "0.0.0.0/0"
  nat_gateway_id         = aws_nat_gateway.nat_gateway.id
}

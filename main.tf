#===========================================================================================================
# creating vpc
#===========================================================================================================
resource "aws_vpc" "vpc" {
  cidr_block           = var.vpc_cidr
  instance_tenancy     = "default"
  enable_dns_hostnames = true
  enable_dns_support   = true
  tags = {
    Name = "${var.project}-${var.environment}"
  }
}

#===========================================================================================================
# creating an internet gateway
#===========================================================================================================
resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.vpc.id
  tags = {
    Name = "${var.project}-${var.environment}"
  }
}

#===========================================================================================================
# creating public subnets
#===========================================================================================================
resource "aws_subnet" "public" {
  count                   = local.subnets
  vpc_id                  = aws_vpc.vpc.id
  cidr_block              = cidrsubnet(var.vpc_cidr, 4, count.index)
  availability_zone       = data.aws_availability_zones.available.names[count.index]
  map_public_ip_on_launch = true
  tags = {
    Name = "${var.project}-${var.environment}-public${count.index + 1}"
  }
}

#===========================================================================================================
# creating private subnets
#===========================================================================================================
resource "aws_subnet" "private" {
  count                   = local.subnets
  vpc_id                  = aws_vpc.vpc.id
  map_public_ip_on_launch = false
  cidr_block              = cidrsubnet(var.vpc_cidr, 4, "${count.index + local.subnets}")
  availability_zone       = data.aws_availability_zones.available.names[count.index]
  tags = {
    Name = "${var.project}-${var.environment}-private${count.index + 1}"
  }
}

#===========================================================================================================
# Elastic IP for NAT gateway
#===========================================================================================================
resource "aws_eip" "nat" {
  count = var.enable_nat_gateway ? 1 : 0
  vpc = true
  tags = {
    Name = "${var.project}-${var.environment}-natgw"
  }
}

#===========================================================================================================
# Creating a NAT gateway
#===========================================================================================================
resource "aws_nat_gateway" "nat" {
  count = var.enable_nat_gateway ? 1 : 0
  allocation_id = aws_eip.nat.0.id
  subnet_id     = aws_subnet.public[0].id
  tags = {
    Name = "${var.project}-${var.environment}"
  }
  depends_on = [aws_internet_gateway.igw]
}

#===========================================================================================================
# Creating a public route table
#===========================================================================================================
resource "aws_route_table" "public" {
  vpc_id = aws_vpc.vpc.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw.id
  }
  tags = {
    Name = "${var.project}-${var.environment}-public"
  }
}

#===========================================================================================================
# Creating a private route table
#===========================================================================================================
resource "aws_route_table" "private" {
  vpc_id = aws_vpc.vpc.id
  tags = {
    Name = "${var.project}-${var.environment}-private"
  }
}

#===========================================================================================================
# Creating a route table entry for NAT in the private route table, if NAT is enabled
#===========================================================================================================
resource "aws_route" "enable_nat" {
  count = var.enable_nat_gateway ? 1 : 0
  route_table_id            = aws_route_table.private.id
  destination_cidr_block    = "0.0.0.0/0"
  nat_gateway_id            = aws_nat_gateway.nat.0.id
  depends_on                = [ aws_route_table.private]
}

#===========================================================================================================
# Public route table association
#===========================================================================================================
resource "aws_route_table_association" "public" {
  count          = local.subnets
  subnet_id      = aws_subnet.public[count.index].id
  route_table_id = aws_route_table.public.id
}

#===========================================================================================================
# Private route table association
#===========================================================================================================
resource "aws_route_table_association" "private" {
  count          = local.subnets
  subnet_id      = aws_subnet.private[count.index].id
  route_table_id = aws_route_table.private.id
}

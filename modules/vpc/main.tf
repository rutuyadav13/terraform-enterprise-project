resource "aws_vpc" "main" {

  cidr_block           = var.vpc_cidr
  enable_dns_hostnames = true
  enable_dns_support   = true

  tags = {
    Name = "main-vpc"
  }
}

resource "aws_subnet" "public_1" {

  vpc_id                  = aws_vpc.main.id
  cidr_block              = var.public_subnet_1_cidr
  availability_zone       = var.availability_zone_1
  map_public_ip_on_launch = true

  tags = {
    Name = "public-subnet-1"
  }
}

resource "aws_subnet" "public_2" {

  vpc_id                  = aws_vpc.main.id
  cidr_block              = var.public_subnet_2_cidr
  availability_zone       = var.availability_zone_2
  map_public_ip_on_launch = true

  tags = {
    Name = "public-subnet-2"
  }
}

resource "aws_subnet" "private_1" {

  vpc_id            = aws_vpc.main.id
  cidr_block        = var.private_subnet_1_cidr
  availability_zone = var.availability_zone_1

  tags = {
    Name = "private-subnet-1"
  }
}

resource "aws_subnet" "private_2" {

  vpc_id            = aws_vpc.main.id
  cidr_block        = var.private_subnet_2_cidr
  availability_zone = var.availability_zone_2

  tags = {
    Name = "private-subnet-2"
  }
}

resource "aws_internet_gateway" "igw" {

  vpc_id = aws_vpc.main.id

  tags = {
    Name = "main-igw"
  }
}

resource "aws_eip" "nat_eip" {

  domain = "vpc"

  tags = {
    Name = "nat-eip"
  }
}

resource "aws_nat_gateway" "nat" {

  allocation_id = aws_eip.nat_eip.id
  subnet_id     = aws_subnet.public_1.id

  depends_on = [
    aws_internet_gateway.igw
  ]

  tags = {
    Name = "nat-gateway"
  }
}

resource "aws_route_table" "public_rt" {

  vpc_id = aws_vpc.main.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw.id
  }

  tags = {
    Name = "public-route-table"
  }
}

resource "aws_route_table_association" "public_1_assoc" {

  subnet_id      = aws_subnet.public_1.id
  route_table_id = aws_route_table.public_rt.id
}

resource "aws_route_table_association" "public_2_assoc" {

  subnet_id      = aws_subnet.public_2.id
  route_table_id = aws_route_table.public_rt.id
}

resource "aws_route_table" "private_rt" {

  vpc_id = aws_vpc.main.id

  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.nat.id
  }

  tags = {
    Name = "private-route-table"
  }
}

resource "aws_route_table_association" "private_1_assoc" {

  subnet_id      = aws_subnet.private_1.id
  route_table_id = aws_route_table.private_rt.id
}

resource "aws_route_table_association" "private_2_assoc" {

  subnet_id      = aws_subnet.private_2.id
  route_table_id = aws_route_table.private_rt.id
}


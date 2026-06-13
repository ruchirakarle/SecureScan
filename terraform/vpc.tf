
resource "aws_vpc" "securescan" {
  cidr_block           = "10.0.0.0/16"
  enable_dns_hostnames = true  
  enable_dns_support   = true
  tags = { Name = "securescan-vpc" }
}

resource "aws_subnet" "public_1" {
  vpc_id            = aws_vpc.securescan.id
  cidr_block        = "10.0.1.0/24"
  availability_zone = "${var.aws_region}a"
  map_public_ip_on_launch = true
  tags = { Name = "securescan-public-1" }
}

resource "aws_subnet" "public_2" {
  vpc_id            = aws_vpc.securescan.id
  cidr_block        = "10.0.2.0/24"
  availability_zone = "${var.aws_region}b"
  map_public_ip_on_launch = true
  tags = { Name = "securescan-public-2" }
}

resource "aws_subnet" "private_1" {
  vpc_id            = aws_vpc.securescan.id
  cidr_block        = "10.0.3.0/24"
  availability_zone = "${var.aws_region}a"
  tags = { Name = "securescan-private-1" }
}

resource "aws_subnet" "private_2" {
  vpc_id            = aws_vpc.securescan.id
  cidr_block        = "10.0.4.0/24"
  availability_zone = "${var.aws_region}b"
  tags = { Name = "securescan-private-2" }
}

resource "aws_internet_gateway" "main" {
  vpc_id = aws_vpc.securescan.id
  tags = { Name = "securescan-igw" }
}

resource "aws_eip" "nat" {
  domain = "vpc"
}

resource "aws_nat_gateway" "main" {
  allocation_id = aws_eip.nat.id
  subnet_id     = aws_subnet.public_1.id
  tags = { Name = "securescan-nat" }
}

resource "aws_route_table" "public" {
  vpc_id = aws_vpc.securescan.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.main.id
  }
  tags = { Name = "securescan-public-rt" }
}

resource "aws_route_table" "private" {
  vpc_id = aws_vpc.securescan.id
  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.main.id
  }
  tags = { Name = "securescan-private-rt" }
}

resource "aws_route_table_association" "public_1" {
  subnet_id      = aws_subnet.public_1.id
  route_table_id = aws_route_table.public.id
}

resource "aws_route_table_association" "public_2" {
  subnet_id      = aws_subnet.public_2.id
  route_table_id = aws_route_table.public.id
}

resource "aws_route_table_association" "private_1" {
  subnet_id      = aws_subnet.private_1.id
  route_table_id = aws_route_table.private.id
}

resource "aws_route_table_association" "private_2" {
  subnet_id      = aws_subnet.private_2.id
  route_table_id = aws_route_table.private.id
}

resource "aws_vpc_endpoint" "s3" {
  vpc_id       = aws_vpc.securescan.id
  service_name = "com.amazonaws.${var.aws_region}.s3"
  route_table_ids = [aws_route_table.private.id]
  tags = { Name = "securescan-s3-endpoint" }
}

output "vpc_id" {
  value = aws_vpc.securescan.id
}

output "public_subnet_1_id" {
  value = aws_subnet.public_1.id
}

output "public_subnet_2_id" {
  value = aws_subnet.public_2.id
}

output "private_subnet_1_id" {
  value = aws_subnet.private_1.id
}

output "private_subnet_2_id" {
  value = aws_subnet.private_2.id
}

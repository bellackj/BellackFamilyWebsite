#####################################
# VPC for BellackFamily.com website #
#####################################
resource "aws_vpc" "bellack_family" {
  cidr_block           = local.vpc_cidr_block
  enable_dns_support   = true
  enable_dns_hostnames = true
  instance_tenancy     = "default"

  tags = merge(local.default_tags, {
    Name   = local.vpc_name
    CIDR   = local.vpc_cidr_block
    Region = local.region
  })
}

###########
# Subnets #
###########
resource "aws_subnet" "public" {
  count = length(local.public_subnets)

  vpc_id            = aws_vpc.bellack_family.id
  availability_zone = local.availability_zones[count.index]
  cidr_block        = local.public_subnets[count.index]

  tags = merge(local.default_tags, {
    Name   = join("-", [local.availability_zones[count.index], "public"])
    CIDR   = local.public_subnets[count.index]
    Region = local.region
  })
}

resource "aws_subnet" "private" {
  count = length(local.private_subnets)

  vpc_id            = aws_vpc.bellack_family.id
  availability_zone = local.availability_zones[count.index]
  cidr_block        = local.private_subnets[count.index]

  tags = merge(local.default_tags, {
    Name   = join("-", [local.availability_zones[count.index], "private"])
    CIDR   = local.private_subnets[count.index]
    Region = local.region
  })
}

####################
# Internet Gateway #
####################
resource "aws_internet_gateway" "bellack" {
  vpc_id = aws_vpc.bellack_family.id

  tags = merge(local.default_tags, {
    Name   = "BellackFamily-IGW"
    Region = local.region
  })
}

###############
# NAT Gateway #
###############
resource "aws_eip" "nat_eip" {
  count = length(local.availability_zones)

  domain = "vpc"

  tags = merge(local.default_tags, {
    Name   = join("-", ["nat-eip", local.availability_zones[count.index]])
    Region = local.region
  })

  depends_on = [aws_internet_gateway.bellack]
}

resource "aws_nat_gateway" "bellack_nat" {
  count = length(local.availability_zones)

  allocation_id = aws_eip.nat_eip[count.index].id
  subnet_id     = aws_subnet.public[count.index].id

  tags = merge(local.default_tags, {
    Name   = join("-", ["NAT", local.availability_zones[count.index]])
    Region = local.region
    Subnet = aws_subnet.public[count.index].id
  })
}
#################
# Public Routes #
#################
resource "aws_route_table" "public" {
  count = length(local.availability_zones)

  vpc_id = aws_vpc.bellack_family.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.bellack.id
  }
}

resource "aws_route_table_association" "public" {
  count = length(aws_subnet.public[*].id)

  subnet_id      = aws_subnet.public[count.index].id
  route_table_id = aws_route_table.public[count.index].id
}

##################
# Private Routes #
##################
resource "aws_route_table" "private" {
  count = length(local.availability_zones)

  vpc_id = aws_vpc.bellack_family.id

  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.bellack_nat[count.index].id
  }
}

resource "aws_route_table_association" "private" {
  count = length(aws_subnet.private[*].id)

  subnet_id      = aws_subnet.private[count.index].id
  route_table_id = aws_route_table.private[count.index].id
}
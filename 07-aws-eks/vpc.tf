resource "aws_vpc" "vpc" {
  cidr_block           = var.vpc_cidr
  enable_dns_hostnames = true
  tags = merge(
    local.common_tags,
    {
      Name = "${var.project_name}-vpc"
    }
  )
}

resource "aws_subnet" "public_subnets" {
  for_each          = local.azs_set
  vpc_id            = aws_vpc.vpc.id
  availability_zone = each.value
  cidr_block = cidrsubnet(
    aws_vpc.vpc.cidr_block,
    8,
    index(local.azs_list, each.value) + 1
  )
  map_public_ip_on_launch = true
  tags = merge(
    local.common_tags,
    {
      Name                     = "${var.project_name}-public-sn-${each.value}"
      "kubernetes.io/role/elb" = 1
    }
  )
}

resource "aws_subnet" "private_subnets" {
  for_each          = local.azs_set
  vpc_id            = aws_vpc.vpc.id
  availability_zone = each.value
  cidr_block = cidrsubnet(
    aws_vpc.vpc.cidr_block,
    8,
    index(local.azs_list, each.value) + 1 + length(local.azs_set)
  )
  tags = merge(
    local.common_tags,
    {
      Name                              = "${var.project_name}-private-sn-${each.value}"
      "kubernetes.io/role/internal-elb" = 1
    }
  )
}

resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.vpc.id

  tags = merge(
    local.common_tags,
    {
      Name = "${var.project_name}-igw"
    }
  )
}

resource "aws_default_route_table" "public_route_table" {
  default_route_table_id = aws_vpc.vpc.default_route_table_id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw.id
  }
  tags = merge(
    local.common_tags,
    {
      Name = "${var.project_name}-public-rt"
    }
  )
}

resource "aws_route_table_association" "public_subnets_association" {
  for_each       = aws_subnet.public_subnets
  subnet_id      = each.value.id
  route_table_id = aws_default_route_table.public_route_table.id
}

resource "aws_eip" "eip" {
  domain               = "vpc"
  network_border_group = var.aws_region
  tags = merge(
    local.common_tags,
    {
      Name = "${var.project_name}-nat-eip"
    }
  )
}

resource "aws_nat_gateway" "natgw" {
  allocation_id = aws_eip.eip.id
  subnet_id     = aws_subnet.public_subnets[local.azs_list[0]].id
  tags = merge(
    local.common_tags,
    {
      Name = "${var.project_name}-natgw"
    }
  )
  depends_on = [aws_internet_gateway.igw]
}

resource "aws_route_table" "private_route_table" {
  vpc_id = aws_vpc.vpc.id
  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.natgw.id
  }
  tags = merge(
    local.common_tags,
    {
      Name = "${var.project_name}-private-rt"
    }
  )
}

resource "aws_route_table_association" "private_subnets_association" {
  for_each       = aws_subnet.private_subnets
  subnet_id      = each.value.id
  route_table_id = aws_route_table.private_route_table.id
}

resource "aws_default_network_acl" "default_nacl" {
  default_network_acl_id = aws_vpc.vpc.default_network_acl_id

  ingress {
    protocol   = -1
    rule_no    = 100
    action     = "allow"
    cidr_block = "0.0.0.0/0"
    from_port  = 0
    to_port    = 0
  }

  egress {
    protocol   = -1
    rule_no    = 100
    action     = "allow"
    cidr_block = "0.0.0.0/0"
    from_port  = 0
    to_port    = 0
  }

  subnet_ids = concat([for subnet in aws_subnet.public_subnets : subnet.id], [for subnet in aws_subnet.private_subnets : subnet.id])

  tags = merge(
    local.common_tags,
    {
      Name = "${var.project_name}-default-nacl"
    }
  )
}

resource "aws_default_security_group" "default_sg" {
  vpc_id = aws_vpc.vpc.id

  ingress {
    protocol  = -1
    self      = true
    from_port = 0
    to_port   = 0
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = -1
    cidr_blocks = ["0.0.0.0/0"]
  }
  tags = merge(
    local.common_tags,
    {
      Name = "${var.project_name}-default-sg"
    }
  )
}
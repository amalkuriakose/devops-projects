output "vpc_id" {
  value = aws_vpc.vpc.id
}

output "public_subnets" {
  value = [for subnet in aws_subnet.public_subnets : subnet.id]
}

output "private_subnets" {
  value = [for subnet in aws_subnet.private_subnets : subnet.id]
}

output "igw_id" {
  value = aws_internet_gateway.igw.id
}

output "natgw_id" {
  value = aws_nat_gateway.natgw.id
}

output "eip_public_ip" {
  value = aws_eip.eip.public_ip
}
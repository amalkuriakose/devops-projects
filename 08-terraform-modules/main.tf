module "sg" {
  source        = "./modules/sg"
  name          = "my-sg"
  description   = "Test Security Group"
  ingress_rules = [
    { ip_protocol = "tcp", from_port = 80, to_port = 80, cidr_ipv4 = "0.0.0.0/0", tags = { Name = "http" }, description = "allow http" },
    { ip_protocol = "tcp", from_port = 22, to_port = 22, cidr_ipv6 = "::/0", tags = { Name = "ssh" }, description = "allow ssh" }
  ]
  egress_rules  = [
    { ip_protocol = "-1", from_port = -1, to_port = -1, cidr_ipv4 = "0.0.0.0/0", tags = { Name = "allowall" }, description = "allo all" }
  ]
  tags = {
    Name = "my-sg"
  }
}
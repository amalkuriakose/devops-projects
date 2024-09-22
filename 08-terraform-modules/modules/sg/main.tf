resource "aws_security_group" "security_group" {
  description            = var.description
  name                   = var.name
  name_prefix            = var.name_prefix
  revoke_rules_on_delete = var.revoke_rules_on_delete
  tags                   = var.tags
  vpc_id                 = var.vpc_id
}

resource "aws_vpc_security_group_ingress_rule" "ingress_rule" {
  security_group_id            = aws_security_group.security_group.id
  count                        = length(var.ingress_rules)
  cidr_ipv4                    = var.ingress_rules[count.index].cidr_ipv4
  cidr_ipv6                    = var.ingress_rules[count.index].cidr_ipv6
  description                  = var.ingress_rules[count.index].description
  from_port                    = var.ingress_rules[count.index].from_port
  ip_protocol                  = var.ingress_rules[count.index].ip_protocol
  prefix_list_id               = var.ingress_rules[count.index].prefix_list_id
  referenced_security_group_id = var.ingress_rules[count.index].referenced_security_group_id
  to_port                      = var.ingress_rules[count.index].to_port
  tags                         = var.ingress_rules[count.index].tags
}

resource "aws_vpc_security_group_egress_rule" "egress_rule" {
  security_group_id            = aws_security_group.security_group.id
  count                        = length(var.egress_rules)
  cidr_ipv4                    = var.egress_rules[count.index].cidr_ipv4
  cidr_ipv6                    = var.egress_rules[count.index].cidr_ipv6
  description                  = var.egress_rules[count.index].description
  from_port                    = var.egress_rules[count.index].from_port
  ip_protocol                  = var.egress_rules[count.index].ip_protocol
  prefix_list_id               = var.egress_rules[count.index].prefix_list_id
  referenced_security_group_id = var.egress_rules[count.index].referenced_security_group_id
  to_port                      = var.egress_rules[count.index].to_port
  tags                         = var.egress_rules[count.index].tags
}
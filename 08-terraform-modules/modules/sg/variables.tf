variable "description" {
  type    = string
  default = "Managed by Terraform"
}

variable "revoke_rules_on_delete" {
  type    = bool
  default = false
}

variable "tags" {
  type    = map(any)
  default = {}
}

variable "vpc_id" {
  type    = string
  default = null
}

variable "name" {
  type    = string
  default = null
}

variable "name_prefix" {
  type    = string
  default = null
}

variable "ingress_rules" {
  type = list(object({
    cidr_ipv4                    = optional(string, null)
    cidr_ipv6                    = optional(string, null)
    description                  = optional(string, null)
    from_port                    = optional(string, null)
    ip_protocol                  = optional(string, null)
    prefix_list_id               = optional(string, null)
    referenced_security_group_id = optional(string, null)
    to_port                      = optional(string, null)
    tags                         = optional(map(any), null)
  }))
  default = []
}

variable "egress_rules" {
  type = list(object({
    cidr_ipv4                    = optional(string, null)
    cidr_ipv6                    = optional(string, null)
    description                  = optional(string, null)
    from_port                    = optional(string, null)
    ip_protocol                  = optional(string, null)
    prefix_list_id               = optional(string, null)
    referenced_security_group_id = optional(string, null)
    to_port                      = optional(string, null)
    tags                         = optional(map(any), null)
  }))
  default = []
}
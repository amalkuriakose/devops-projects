variable "aws_region" {
  type = string
}

variable "vpc_cidr" {
  type        = string
  description = "The VPC CIDR. Please enter the value in following format X.X.X.X/16."

  validation {
    condition     = can(cidrhost(var.vpc_cidr, 32))
    error_message = "Must be valid IPv4 CIDR."
  }
}

variable "project_name" {
  type = string
}

variable "eks_cluster_service_role_name" {
  type = string
}

variable "eks_node_role_name" {
  type = string
}

variable "eks_cluster_name" {
  type = string
}

variable "eks_ng_name" {
  type = string
}

variable "k8s_version" {
  type = string
}

variable "node_instance_type" {
  type = string
}
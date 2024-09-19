locals {
  common_tags = {
    created-by = "Terraform"
  }
  azs_set  = toset(data.aws_availability_zones.availability_zones.names)
  azs_list = tolist(data.aws_availability_zones.availability_zones.names)
}
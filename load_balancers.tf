#-------------------------------------------------------------------------------
# Create the FreeIPA cluster load balancers.
#-------------------------------------------------------------------------------

locals {
  # The IDs of the subnets where the IPA servers are to be placed
  subnet_ids = [for subnet in data.terraform_remote_state.networking.outputs.private_subnets : subnet.id]
}

# FreeIPA network load balancer
resource "aws_lb" "nlb" {
  provider = aws.sharedservicesprovisionaccount

  enable_cross_zone_load_balancing = true
  internal                         = true
  load_balancer_type               = "network"
  name                             = "IPA"
  subnets                          = local.subnet_ids
}

# FreeIPA application load balancer
resource "aws_lb" "alb" {
  provider = aws.sharedservicesprovisionaccount

  enable_cross_zone_load_balancing = true
  internal                         = true
  load_balancer_type               = "application"
  name                             = "IPA"
  security_groups = [
    module.security_groups.server.id,
  ]
  subnets = local.subnet_ids
}

# This is currently the only way to get the ELB private IPs via
# Terraform
data "aws_network_interface" "nlb" {
  for_each = toset(local.subnet_ids)
  provider = aws.sharedservicesprovisionaccount

  filter {
    name   = "description"
    values = ["ELB ${aws_lb.nlb.arn_suffix}"]
  }

  filter {
    name   = "subnet-id"
    values = [each.value]
  }
}

#-------------------------------------------------------------------------------
# Create the load balancer target groups.
#-------------------------------------------------------------------------------

locals {
  # The ports used to communicate with IPA servers.
  ipa_ports = {
    http = {
      protocol = "TCP",
      port     = 80,
    },
    kinit = {
      protocol = "TCP_UDP",
      port     = 88,
    },
    https = {
      protocol = "TCP",
      port     = 443,
    },
    kpasswd = {
      protocol = "TCP_UDP",
      port     = 464,
    },
    ldap = {
      protocol = "TCP",
      port     = 389,
    },
    ldaps = {
      protocol = "TLS",
      port     = 636,
    }
  }
}

# FreeIPA network load balancer target groups
#
# HTTP and HTTPS gets sent to the ALB, while everything else gets sent
# directly to the IPA instances.
resource "aws_lb_target_group" "nlb_not_tls" {
  for_each = { for key, value in local.ipa_ports : key => value if value.protocol != "TLS" }
  provider = aws.sharedservicesprovisionaccount

  name     = each.key
  port     = each.value.port
  protocol = each.value.protocol
  stickiness {
    type = "source_ip"
  }
  # HTTP and HTTPS will target the ALB, but everything else targets
  # the instances directly.
  target_type = contains([80, 443], each.value.port) ? "alb" : "instance"
  vpc_id      = data.terraform_remote_state.networking.outputs.vpc.id
}
resource "aws_lb_target_group" "nlb_tls" {
  for_each = { for key, value in local.ipa_ports : key => value if value.protocol == "TLS" }
  provider = aws.sharedservicesprovisionaccount

  name     = each.key
  port     = each.value.port
  protocol = each.value.protocol
  # TLS target groups do not allow for stickiness.
  #
  # HTTP and HTTPS will target the ALB, but everything else targets
  # the instances directly.
  target_type = contains([80, 443], each.value.port) ? "alb" : "instance"
  vpc_id      = data.terraform_remote_state.networking.outputs.vpc.id
}

# FreeIPA application load balancer target groups
resource "aws_lb_target_group" "alb_http" {
  provider = aws.sharedservicesprovisionaccount

  health_check {
    # The response should be a redirect to HTTPS
    matcher  = "308"
    path     = "/ipa/ui/"
    protocol = "HTTP"
  }
  name     = "HTTP"
  port     = 80
  protocol = "HTTP"
  # Send HTTP/2 requests to targets
  protocol_version = "HTTP2"
  stickiness {
    type = "lb_cookie"
  }
  target_type = "instance"
  vpc_id      = data.terraform_remote_state.networking.outputs.vpc.id
}
resource "aws_lb_target_group" "alb_https" {
  provider = aws.sharedservicesprovisionaccount

  health_check {
    matcher  = "200,308"
    path     = "/ipa/ui/"
    protocol = "HTTPS"
  }
  name     = "HTTPS"
  port     = 443
  protocol = "HTTPS"
  # Send HTTP/2 requests to targets
  protocol_version = "HTTP2"
  stickiness {
    type = "lb_cookie"
  }
  target_type = "instance"
  vpc_id      = data.terraform_remote_state.networking.outputs.vpc.id
}

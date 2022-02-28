#-------------------------------------------------------------------------------
# Configure the master and replica modules.
#-------------------------------------------------------------------------------

locals {
  # The subnets where the IPA servers are to be placed
  subnet_cidrs = keys(data.terraform_remote_state.networking.outputs.private_subnets)

  # The IP addresses of the IPA servers.  AWS reserves the first four
  # and the last IP address in each subnet.
  #
  # cisagov/freeipa-server-tf-module now requires us to assign IPs in
  # order to break the dependency of DNS record resources on the
  # corresponding EC2 instance resources; otherwise, it is not
  # possible to recreate the IPA servers one by one as is required
  # when a new FreeIPA AMI is made available.
  ipa_ips = [for cidr in local.subnet_cidrs : cidrhost(cidr, 4)]

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

# Create the IPA client and server security groups
module "security_groups" {
  source = "./security_groups"
  providers = {
    aws = aws.sharedservicesprovisionaccount
  }

  load_balancer_ips   = [for i in data.aws_network_interface.nlb : i.private_ip]
  trusted_cidr_blocks = var.trusted_cidr_blocks
  vpc_id              = data.terraform_remote_state.networking.outputs.vpc.id
}

# Create the IPA servers
module "ipa0" {
  source = "github.com/cisagov/freeipa-server-tf-module"
  providers = {
    aws                                   = aws.sharedservicesprovisionaccount_ipa0
    aws.provision_ssm_parameter_read_role = aws.provision_ssm_parameter_read_role
  }

  ami_owner_account_id = local.images_account_id
  domain               = var.cool_domain
  hostname             = "ipa0.${var.cool_domain}"
  ip                   = local.ipa_ips[0]
  nessus_hostname_key  = var.nessus_hostname_key
  nessus_key_key       = var.nessus_key_key
  nessus_port_key      = var.nessus_port_key
  netbios_name         = var.netbios_name
  realm                = upper(var.cool_domain)
  root_disk_size       = var.root_disk_size
  security_group_ids = [
    module.security_groups.server.id,
    data.terraform_remote_state.cdm.outputs.cdm_security_group.id,
  ]
  subnet_id = data.terraform_remote_state.networking.outputs.private_subnets[local.subnet_cidrs[0]].id
}
module "ipa1" {
  source = "github.com/cisagov/freeipa-server-tf-module"
  providers = {
    aws                                   = aws.sharedservicesprovisionaccount_ipa1
    aws.provision_ssm_parameter_read_role = aws.provision_ssm_parameter_read_role
  }

  ami_owner_account_id = local.images_account_id
  domain               = var.cool_domain
  hostname             = "ipa1.${var.cool_domain}"
  ip                   = local.ipa_ips[1]
  nessus_hostname_key  = var.nessus_hostname_key
  nessus_key_key       = var.nessus_key_key
  nessus_port_key      = var.nessus_port_key
  netbios_name         = var.netbios_name
  root_disk_size       = var.root_disk_size
  security_group_ids = [
    module.security_groups.server.id,
    data.terraform_remote_state.cdm.outputs.cdm_security_group.id,
  ]
  subnet_id = data.terraform_remote_state.networking.outputs.private_subnets[local.subnet_cidrs[1]].id
}
module "ipa2" {
  source = "github.com/cisagov/freeipa-server-tf-module"
  providers = {
    aws                                   = aws.sharedservicesprovisionaccount_ipa2
    aws.provision_ssm_parameter_read_role = aws.provision_ssm_parameter_read_role
  }

  ami_owner_account_id = local.images_account_id
  domain               = var.cool_domain
  hostname             = "ipa2.${var.cool_domain}"
  ip                   = local.ipa_ips[2]
  nessus_hostname_key  = var.nessus_hostname_key
  nessus_key_key       = var.nessus_key_key
  nessus_port_key      = var.nessus_port_key
  netbios_name         = var.netbios_name
  root_disk_size       = var.root_disk_size
  security_group_ids = [
    module.security_groups.server.id,
    data.terraform_remote_state.cdm.outputs.cdm_security_group.id,
  ]
  subnet_id = data.terraform_remote_state.networking.outputs.private_subnets[local.subnet_cidrs[2]].id
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
  target_type = contains([80, 443], each.value.port) ? "alb" : "instance"
  vpc_id      = data.terraform_remote_state.networking.outputs.vpc.id
}
resource "aws_lb_target_group" "nlb_tls" {
  for_each = { for key, value in local.ipa_ports : key => value if value.protocol == "TLS" }
  provider = aws.sharedservicesprovisionaccount

  name     = each.key
  port     = each.value.port
  protocol = each.value.protocol
  # TLS target groups do not allow for stickiness
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

# FreeIPA network load balancer target group attachments
#
# HTTP and HTTPS gets sent to the ALB, while everything else gets sent
# directly to the IPA instances.
resource "aws_lb_target_group_attachment" "nlb_alb" {
  for_each = { for key, value in aws_lb_target_group.nlb_not_tls : key => value if contains([80, 443], value.port) }
  provider = aws.sharedservicesprovisionaccount

  port             = each.value.port
  target_group_arn = each.value.arn
  target_id        = aws_lb.alb.id
}
resource "aws_lb_target_group_attachment" "nlb_not_tls_ipa0" {
  for_each = { for key, value in aws_lb_target_group.nlb_not_tls : key => value if !contains([80, 443], value.port) }
  provider = aws.sharedservicesprovisionaccount

  port             = each.value.port
  target_group_arn = each.value.arn
  target_id        = module.ipa0.server.id
}
resource "aws_lb_target_group_attachment" "nlb_tls_ipa0" {
  for_each = { for key, value in aws_lb_target_group.nlb_tls : key => value if !contains([80, 443], value.port) }
  provider = aws.sharedservicesprovisionaccount

  port             = each.value.port
  target_group_arn = each.value.arn
  target_id        = module.ipa0.server.id
}
resource "aws_lb_target_group_attachment" "nlb_not_tls_ipa1" {
  for_each = { for key, value in aws_lb_target_group.nlb_not_tls : key => value if !contains([80, 443], value.port) }
  provider = aws.sharedservicesprovisionaccount

  port             = each.value.port
  target_group_arn = each.value.arn
  target_id        = module.ipa1.server.id
}
resource "aws_lb_target_group_attachment" "nlb_tls_ipa1" {
  for_each = { for key, value in aws_lb_target_group.nlb_tls : key => value if !contains([80, 443], value.port) }
  provider = aws.sharedservicesprovisionaccount

  port             = each.value.port
  target_group_arn = each.value.arn
  target_id        = module.ipa1.server.id
}
resource "aws_lb_target_group_attachment" "nlb_not_tls_ipa2" {
  for_each = { for key, value in aws_lb_target_group.nlb_not_tls : key => value if !contains([80, 443], value.port) }
  provider = aws.sharedservicesprovisionaccount

  port             = each.value.port
  target_group_arn = each.value.arn
  target_id        = module.ipa2.server.id
}
resource "aws_lb_target_group_attachment" "nlb_tls_ipa2" {
  for_each = { for key, value in aws_lb_target_group.nlb_tls : key => value if !contains([80, 443], value.port) }
  provider = aws.sharedservicesprovisionaccount

  port             = each.value.port
  target_group_arn = each.value.arn
  target_id        = module.ipa2.server.id
}


# FreeIPA application load balancer target group attachments
resource "aws_lb_target_group_attachment" "alb_http_0" {
  provider = aws.sharedservicesprovisionaccount

  port             = 80
  target_group_arn = aws_lb_target_group.alb_http.arn
  target_id        = module.ipa0.server.id
}
resource "aws_lb_target_group_attachment" "alb_http_1" {
  provider = aws.sharedservicesprovisionaccount

  port             = 80
  target_group_arn = aws_lb_target_group.alb_http.arn
  target_id        = module.ipa1.server.id
}
resource "aws_lb_target_group_attachment" "alb_http_2" {
  provider = aws.sharedservicesprovisionaccount

  port             = 80
  target_group_arn = aws_lb_target_group.alb_http.arn
  target_id        = module.ipa2.server.id
}
resource "aws_lb_target_group_attachment" "alb_https_0" {
  provider = aws.sharedservicesprovisionaccount

  port             = 443
  target_group_arn = aws_lb_target_group.alb_https.arn
  target_id        = module.ipa0.server.id
}
resource "aws_lb_target_group_attachment" "alb_https_1" {
  provider = aws.sharedservicesprovisionaccount

  port             = 443
  target_group_arn = aws_lb_target_group.alb_https.arn
  target_id        = module.ipa1.server.id
}
resource "aws_lb_target_group_attachment" "alb_https_2" {
  provider = aws.sharedservicesprovisionaccount

  port             = 443
  target_group_arn = aws_lb_target_group.alb_https.arn
  target_id        = module.ipa2.server.id
}

# Create the DNS entries for the IPA cluster
module "dns" {
  source = "./dns"
  providers = {
    aws = aws.sharedservicesprovisionaccount
  }

  domain                 = var.cool_domain
  hostname               = "ipa"
  load_balancer_dns_name = aws_lb.nlb.dns_name
  load_balancer_zone_id  = aws_lb.nlb.zone_id
  ttl                    = var.ttl
  zone_id                = data.terraform_remote_state.networking.outputs.private_zone.id
}

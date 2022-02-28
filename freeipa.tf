#-------------------------------------------------------------------------------
# Configure the master and replica modules.
#-------------------------------------------------------------------------------

locals {
  # The subnets where the IPA servers are to be placed
  subnet_cidrs = keys(data.terraform_remote_state.networking.outputs.private_subnets)
  subnet_ids   = [for subnet in data.terraform_remote_state.networking.outputs.private_subnets : subnet.id]

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

# Create the IPA client and server security groups
module "security_groups" {
  source = "./security_groups"
  providers = {
    aws = aws.sharedservicesprovisionaccount
  }

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

# AWS certificate for load balancers
resource "aws_acm_certificate" "ipa" {
  provider = aws.sharedservicesprovisionaccount

  domain_name = "ipa.${var.cool_domain}"
  subject_alternative_names = [
    "ipa-ca.${var.cool_domain}",
    "ipa0.${var.cool_domain}",
    "ipa1.${var.cool_domain}",
    "ipa2.${var.cool_domain}",
  ]
  validation_method = "DNS"

  lifecycle {
    create_before_destroy = true
  }
}
resource "aws_route53_record" "ipa_cert_validation" {
  for_each = {
    for dvo in aws_acm_certificate.ipa.domain_validation_options : dvo.domain_name => {
      name   = dvo.resource_record_name
      record = dvo.resource_record_value
      type   = dvo.resource_record_type
    }
  }
  provider = aws.public_dns

  allow_overwrite = true
  name            = each.value.name
  records         = [each.value.record]
  ttl             = 60
  type            = each.value.type
  zone_id         = data.terraform_remote_state.public_dns.outputs.cyber_dhs_gov_zone.id
}
resource "aws_acm_certificate_validation" "ipa" {
  provider = aws.sharedservicesprovisionaccount

  certificate_arn         = aws_acm_certificate.ipa.arn
  validation_record_fqdns = [for record in aws_route53_record.ipa_cert_validation : record.fqdn]
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
  stickiness {
    type = "lb_cookie"
  }
  target_type = "instance"
  vpc_id      = data.terraform_remote_state.networking.outputs.vpc.id
}

# FreeIPA network load balancer listeners
resource "aws_lb_listener" "nlb_not_tls" {
  for_each = aws_lb_target_group.nlb_not_tls
  provider = aws.sharedservicesprovisionaccount

  load_balancer_arn = aws_lb.nlb.arn
  port              = each.value.port
  protocol          = each.value.protocol

  default_action {
    target_group_arn = each.value.arn
    type             = "forward"
  }
}
resource "aws_lb_listener" "nlb_tls" {
  depends_on = [
    aws_acm_certificate_validation.ipa,
  ]
  for_each = aws_lb_target_group.nlb_tls
  provider = aws.sharedservicesprovisionaccount

  load_balancer_arn = aws_lb.nlb.arn
  port              = each.value.port
  protocol          = each.value.protocol
  ssl_policy        = "ELBSecurityPolicy-TLS13-1-2-2021-06"
  certificate_arn   = aws_acm_certificate.ipa.arn

  default_action {
    target_group_arn = each.value.arn
    type             = "forward"
  }
}

# FreeIPA application load balancer listeners
resource "aws_lb_listener" "alb_http" {
  provider = aws.sharedservicesprovisionaccount

  load_balancer_arn = aws_lb.alb.arn
  port              = 80
  protocol          = "HTTP"

  default_action {
    target_group_arn = aws_lb_target_group.alb_http.arn
    type             = "forward"
  }
}
resource "aws_lb_listener" "alb_https" {
  depends_on = [
    aws_acm_certificate_validation.ipa,
  ]
  provider = aws.sharedservicesprovisionaccount

  load_balancer_arn = aws_lb.alb.arn
  port              = 443
  protocol          = "HTTPS"
  ssl_policy        = "ELBSecurityPolicy-TLS-1-2-2017-01"
  certificate_arn   = aws_acm_certificate.ipa.arn

  default_action {
    target_group_arn = aws_lb_target_group.alb_https.arn
    type             = "forward"
  }
}

# Create the DNS entries for the IPA cluster
module "dns" {
  source = "./dns"
  providers = {
    aws = aws.sharedservicesprovisionaccount
  }

  domain = var.cool_domain
  hosts = {
    "ipa0.${var.cool_domain}" = {
      ip              = local.ipa_ips[0]
      reverse_zone_id = data.terraform_remote_state.networking.outputs.private_subnet_private_reverse_zones[local.subnet_cidrs[0]].id
      advertise       = var.advertise_ipa_servers["ipa0"]
    }
    "ipa1.${var.cool_domain}" = {
      ip              = local.ipa_ips[1]
      reverse_zone_id = data.terraform_remote_state.networking.outputs.private_subnet_private_reverse_zones[local.subnet_cidrs[1]].id
      advertise       = var.advertise_ipa_servers["ipa1"]
    }
    "ipa2.${var.cool_domain}" = {
      ip              = local.ipa_ips[2]
      reverse_zone_id = data.terraform_remote_state.networking.outputs.private_subnet_private_reverse_zones[local.subnet_cidrs[2]].id
      advertise       = var.advertise_ipa_servers["ipa2"]
    }
  }
  ttl     = var.ttl
  zone_id = data.terraform_remote_state.networking.outputs.private_zone.id
}

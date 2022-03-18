#-------------------------------------------------------------------------------
# Create all necessary DNS records for the IPA servers.
# -------------------------------------------------------------------------------
locals {
  # The Route53 zone where the IPA server DNS records should be
  # created.
  zone_id = data.terraform_remote_state.networking.outputs.private_zone.id

  # Route53 reverse zones corresponding to the subnets where the
  # FreeIPA servers reside.
  reverse_zone_ids = [for zone in data.terraform_remote_state.networking.outputs.private_subnet_private_reverse_zones : zone.id]
}

resource "aws_route53_record" "server_A" {
  for_each = {
    "${module.ipa0.server.id}" = { hostname = "ipa0", count = 0 }
    "${module.ipa1.server.id}" = { hostname = "ipa1", count = 1 }
    "${module.ipa2.server.id}" = { hostname = "ipa2", count = 2 }
  }
  provider = aws.sharedservicesprovisionaccount

  name    = "${each.value.hostname}.${var.cool_domain}"
  records = [local.ipa_ips[each.value.count]]
  ttl     = var.ttl
  type    = "A"
  zone_id = local.zone_id
}

resource "aws_route53_record" "server_PTR" {
  for_each = {
    "${module.ipa0.server.id}" = { hostname = "ipa0", count = 0 }
    "${module.ipa1.server.id}" = { hostname = "ipa1", count = 1 }
    "${module.ipa2.server.id}" = { hostname = "ipa2", count = 2 }
  }
  provider = aws.sharedservicesprovisionaccount

  name = format(
    "%s.%s.%s.%s.in-addr.arpa.",
    element(split(".", local.ipa_ips[each.value.count]), 3),
    element(split(".", local.ipa_ips[each.value.count]), 2),
    element(split(".", local.ipa_ips[each.value.count]), 1),
    element(split(".", local.ipa_ips[each.value.count]), 0),
  )
  records = ["${each.value.hostname}.${var.cool_domain}"]
  ttl     = var.ttl
  type    = "PTR"
  zone_id = local.reverse_zone_ids[each.value.count]
}

resource "aws_route53_record" "ipa_A" {
  for_each = {
    "${module.ipa0.server.id}" = { hostname = "ipa0", server = module.ipa0.server }
    "${module.ipa1.server.id}" = { hostname = "ipa1", server = module.ipa1.server }
    "${module.ipa2.server.id}" = { hostname = "ipa2", server = module.ipa2.server }
  }
  provider = aws.sharedservicesprovisionaccount

  health_check_id = aws_route53_health_check.overall[each.key].id
  name            = "ipa.${var.cool_domain}"
  ttl             = var.ttl
  type            = "A"
  records = [
    each.value.server.private_ip,
  ]
  set_identifier = each.value.hostname
  weighted_routing_policy {
    weight = 10
  }
  zone_id = local.zone_id
}

resource "aws_route53_record" "ca_A" {
  for_each = {
    "${module.ipa0.server.id}" = { hostname = "ipa0", server = module.ipa0.server }
    "${module.ipa1.server.id}" = { hostname = "ipa1", server = module.ipa1.server }
    "${module.ipa2.server.id}" = { hostname = "ipa2", server = module.ipa2.server }
  }
  provider = aws.sharedservicesprovisionaccount

  health_check_id = aws_route53_health_check.overall[each.key].id
  name            = "ipa-ca.${var.cool_domain}"
  ttl             = var.ttl
  type            = "A"
  records = [
    each.value.server.private_ip,
  ]
  set_identifier = each.value.hostname
  weighted_routing_policy {
    weight = 10
  }
  zone_id = local.zone_id
}

resource "aws_route53_record" "kerberos_TXT" {
  provider = aws.sharedservicesprovisionaccount

  name    = "_kerberos.${var.cool_domain}"
  records = [upper(var.cool_domain)]
  ttl     = var.ttl
  type    = "TXT"
  zone_id = local.zone_id
}

resource "aws_route53_record" "master_tcp_SRV" {
  for_each = {
    "${module.ipa0.server.id}" = { hostname = "ipa0", server = module.ipa0.server }
    "${module.ipa1.server.id}" = { hostname = "ipa1", server = module.ipa1.server }
    "${module.ipa2.server.id}" = { hostname = "ipa2", server = module.ipa2.server }
  }
  provider = aws.sharedservicesprovisionaccount

  health_check_id = aws_route53_health_check.overall[each.key].id
  name            = "_kerberos-master._tcp.${var.cool_domain}"
  records = [
    "0 10 88 ${each.value.hostname}.${var.cool_domain}",
  ]
  set_identifier = each.value.hostname
  ttl            = var.ttl
  type           = "SRV"
  weighted_routing_policy {
    weight = 10
  }
  zone_id = local.zone_id
}

resource "aws_route53_record" "master_udp_SRV" {
  for_each = {
    "${module.ipa0.server.id}" = { hostname = "ipa0", server = module.ipa0.server }
    "${module.ipa1.server.id}" = { hostname = "ipa1", server = module.ipa1.server }
    "${module.ipa2.server.id}" = { hostname = "ipa2", server = module.ipa2.server }
  }
  provider = aws.sharedservicesprovisionaccount

  health_check_id = aws_route53_health_check.overall[each.key].id
  name            = "_kerberos-master._udp.${var.cool_domain}"
  records = [
    "0 10 88 ${each.value.hostname}.${var.cool_domain}",
  ]
  set_identifier = each.value.hostname
  ttl            = var.ttl
  type           = "SRV"
  weighted_routing_policy {
    weight = 10
  }
  zone_id = local.zone_id
}

resource "aws_route53_record" "server_tcp_SRV" {
  for_each = {
    "${module.ipa0.server.id}" = { hostname = "ipa0", server = module.ipa0.server }
    "${module.ipa1.server.id}" = { hostname = "ipa1", server = module.ipa1.server }
    "${module.ipa2.server.id}" = { hostname = "ipa2", server = module.ipa2.server }
  }
  provider = aws.sharedservicesprovisionaccount

  health_check_id = aws_route53_health_check.overall[each.key].id
  name            = "_kerberos._tcp.${var.cool_domain}"
  records = [
    "0 10 88 ${each.value.hostname}.${var.cool_domain}",
  ]
  set_identifier = each.value.hostname
  ttl            = var.ttl
  type           = "SRV"
  weighted_routing_policy {
    weight = 10
  }
  zone_id = local.zone_id
}

resource "aws_route53_record" "server_udp_SRV" {
  for_each = {
    "${module.ipa0.server.id}" = { hostname = "ipa0", server = module.ipa0.server }
    "${module.ipa1.server.id}" = { hostname = "ipa1", server = module.ipa1.server }
    "${module.ipa2.server.id}" = { hostname = "ipa2", server = module.ipa2.server }
  }
  provider = aws.sharedservicesprovisionaccount

  health_check_id = aws_route53_health_check.overall[each.key].id
  name            = "_kerberos._udp.${var.cool_domain}"
  records = [
    "0 10 88 ${each.value.hostname}.${var.cool_domain}",
  ]
  set_identifier = each.value.hostname
  ttl            = var.ttl
  type           = "SRV"
  weighted_routing_policy {
    weight = 10
  }
  zone_id = local.zone_id
}

resource "aws_route53_record" "password_tcp_SRV" {
  for_each = {
    "${module.ipa0.server.id}" = { hostname = "ipa0", server = module.ipa0.server }
    "${module.ipa1.server.id}" = { hostname = "ipa1", server = module.ipa1.server }
    "${module.ipa2.server.id}" = { hostname = "ipa2", server = module.ipa2.server }
  }
  provider = aws.sharedservicesprovisionaccount

  health_check_id = aws_route53_health_check.overall[each.key].id
  name            = "_kpasswd._tcp.${var.cool_domain}"
  records = [
    "0 10 464 ${each.value.hostname}.${var.cool_domain}",
  ]
  set_identifier = each.value.hostname
  ttl            = var.ttl
  type           = "SRV"
  weighted_routing_policy {
    weight = 10
  }
  zone_id = local.zone_id
}

resource "aws_route53_record" "password_udp_SRV" {
  for_each = {
    "${module.ipa0.server.id}" = { hostname = "ipa0", server = module.ipa0.server }
    "${module.ipa1.server.id}" = { hostname = "ipa1", server = module.ipa1.server }
    "${module.ipa2.server.id}" = { hostname = "ipa2", server = module.ipa2.server }
  }
  provider = aws.sharedservicesprovisionaccount

  health_check_id = aws_route53_health_check.overall[each.key].id
  name            = "_kpasswd._udp.${var.cool_domain}"
  records = [
    "0 10 464 ${each.value.hostname}.${var.cool_domain}",
  ]
  set_identifier = each.value.hostname
  ttl            = var.ttl
  type           = "SRV"
  weighted_routing_policy {
    weight = 10
  }
  zone_id = local.zone_id
}

resource "aws_route53_record" "ldap_SRV" {
  for_each = {
    "${module.ipa0.server.id}" = { hostname = "ipa0", server = module.ipa0.server }
    "${module.ipa1.server.id}" = { hostname = "ipa1", server = module.ipa1.server }
    "${module.ipa2.server.id}" = { hostname = "ipa2", server = module.ipa2.server }
  }
  provider = aws.sharedservicesprovisionaccount

  health_check_id = aws_route53_health_check.overall[each.key].id
  name            = "_ldap._tcp.${var.cool_domain}"
  records = [
    "0 10 389 ${each.value.hostname}.${var.cool_domain}",
  ]
  set_identifier = each.value.hostname
  ttl            = var.ttl
  type           = "SRV"
  weighted_routing_policy {
    weight = 10
  }
  zone_id = local.zone_id
}

resource "aws_route53_record" "ldaps_SRV" {
  for_each = {
    "${module.ipa0.server.id}" = { hostname = "ipa0", server = module.ipa0.server }
    "${module.ipa1.server.id}" = { hostname = "ipa1", server = module.ipa1.server }
    "${module.ipa2.server.id}" = { hostname = "ipa2", server = module.ipa2.server }
  }
  provider = aws.sharedservicesprovisionaccount

  health_check_id = aws_route53_health_check.overall[each.key].id
  name            = "_ldaps._tcp.${var.cool_domain}"
  records = [
    "0 10 636 ${each.value.hostname}.${var.cool_domain}",
  ]
  set_identifier = each.value.hostname
  ttl            = var.ttl
  type           = "SRV"
  weighted_routing_policy {
    weight = 10
  }
  zone_id = local.zone_id
}

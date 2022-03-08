#-------------------------------------------------------------------------------
# Create all necessary DNS records for the IPA servers.
# -------------------------------------------------------------------------------
locals {
  tcp_and_udp = {
    tcp = "tcp",
    udp = "udp",
  }

  # The Route53 zone where the IPA server DNS records should be
  # created.
  zone_id = data.terraform_remote_state.networking.outputs.private_zone.id

  # Route53 reverse zones corresponding to the subnets where the
  # FreeIPA servers reside.
  reverse_zone_ids = [for zone in data.terraform_remote_state.networking.outputs.private_subnet_private_reverse_zones : zone.id]
}

resource "aws_route53_record" "server0_A" {
  provider = aws.sharedservicesprovisionaccount

  zone_id = local.zone_id
  name    = "ipa0.${var.cool_domain}"
  type    = "A"
  ttl     = var.ttl
  records = [
    local.ipa_ips[0],
  ]
}
resource "aws_route53_record" "server1_A" {
  provider = aws.sharedservicesprovisionaccount

  zone_id = local.zone_id
  name    = "ipa1.${var.cool_domain}"
  type    = "A"
  ttl     = var.ttl
  records = [
    local.ipa_ips[1],
  ]
}
resource "aws_route53_record" "server2_A" {
  provider = aws.sharedservicesprovisionaccount

  zone_id = local.zone_id
  name    = "ipa2.${var.cool_domain}"
  type    = "A"
  ttl     = var.ttl
  records = [
    local.ipa_ips[2],
  ]
}

resource "aws_route53_record" "server0_PTR" {
  provider = aws.sharedservicesprovisionaccount

  zone_id = local.reverse_zone_ids[0]
  name = format(
    "%s.%s.%s.%s.in-addr.arpa.",
    element(split(".", local.ipa_ips[0]), 3),
    element(split(".", local.ipa_ips[0]), 2),
    element(split(".", local.ipa_ips[0]), 1),
    element(split(".", local.ipa_ips[0]), 0),
  )
  type = "PTR"
  ttl  = var.ttl
  records = [
    "ipa0.${var.cool_domain}",
  ]
}
resource "aws_route53_record" "server1_PTR" {
  provider = aws.sharedservicesprovisionaccount

  zone_id = local.reverse_zone_ids[1]
  name = format(
    "%s.%s.%s.%s.in-addr.arpa.",
    element(split(".", local.ipa_ips[1]), 3),
    element(split(".", local.ipa_ips[1]), 2),
    element(split(".", local.ipa_ips[1]), 1),
    element(split(".", local.ipa_ips[1]), 0),
  )
  type = "PTR"
  ttl  = var.ttl
  records = [
    "ipa1.${var.cool_domain}",
  ]
}
resource "aws_route53_record" "server2_PTR" {
  provider = aws.sharedservicesprovisionaccount

  zone_id = local.reverse_zone_ids[2]
  name = format(
    "%s.%s.%s.%s.in-addr.arpa.",
    element(split(".", local.ipa_ips[2]), 3),
    element(split(".", local.ipa_ips[2]), 2),
    element(split(".", local.ipa_ips[2]), 1),
    element(split(".", local.ipa_ips[2]), 0),
  )
  type = "PTR"
  ttl  = var.ttl
  records = [
    "ipa2.${var.cool_domain}",
  ]
}

resource "aws_route53_record" "ca_A" {
  provider = aws.sharedservicesprovisionaccount

  zone_id = local.zone_id
  name    = "ipa-ca.${var.cool_domain}"
  type    = "A"
  ttl     = var.ttl
  records = local.ipa_ips
}

resource "aws_route53_record" "kerberos_TXT" {
  provider = aws.sharedservicesprovisionaccount

  zone_id = local.zone_id
  name    = "_kerberos.${var.cool_domain}"
  type    = "TXT"
  ttl     = var.ttl
  records = [
    upper(var.cool_domain),
  ]
}

resource "aws_route53_record" "master_SRV" {
  for_each = local.tcp_and_udp
  provider = aws.sharedservicesprovisionaccount

  zone_id = local.zone_id
  name    = "_kerberos-master._${each.value}.${var.cool_domain}"
  type    = "SRV"
  ttl     = var.ttl
  records = [
    "0 100 88 ipa0.${var.cool_domain}",
    "0 100 88 ipa1.${var.cool_domain}",
    "0 100 88 ipa2.${var.cool_domain}",
  ]
}

resource "aws_route53_record" "server_SRV" {
  for_each = local.tcp_and_udp
  provider = aws.sharedservicesprovisionaccount

  zone_id = local.zone_id
  name    = "_kerberos._${each.value}.${var.cool_domain}"
  type    = "SRV"
  ttl     = var.ttl
  records = [
    "0 100 88 ipa0.${var.cool_domain}",
    "0 100 88 ipa1.${var.cool_domain}",
    "0 100 88 ipa2.${var.cool_domain}",
  ]
}

resource "aws_route53_record" "password_SRV" {
  for_each = local.tcp_and_udp
  provider = aws.sharedservicesprovisionaccount

  zone_id = local.zone_id
  name    = "_kpasswd._${each.value}.${var.cool_domain}"
  type    = "SRV"
  ttl     = var.ttl
  records = [
    "0 100 464 ipa0.${var.cool_domain}",
    "0 100 464 ipa1.${var.cool_domain}",
    "0 100 464 ipa2.${var.cool_domain}",
  ]
}

resource "aws_route53_record" "ldap_SRV" {
  provider = aws.sharedservicesprovisionaccount

  zone_id = local.zone_id
  name    = "_ldap._tcp.${var.cool_domain}"
  type    = "SRV"
  ttl     = var.ttl
  records = [
    "0 100 389 ipa0.${var.cool_domain}",
    "0 100 389 ipa1.${var.cool_domain}",
    "0 100 389 ipa2.${var.cool_domain}",
  ]
}

resource "aws_route53_record" "ldaps_SRV" {
  provider = aws.sharedservicesprovisionaccount

  zone_id = local.zone_id
  name    = "_ldaps._tcp.${var.cool_domain}"
  type    = "SRV"
  ttl     = var.ttl
  records = [
    "0 100 636 ipa0.${var.cool_domain}",
    "0 100 636 ipa1.${var.cool_domain}",
    "0 100 636 ipa2.${var.cool_domain}",
  ]
}

#-------------------------------------------------------------------------------
# Create all necessary DNS records for the master IPA server.
# -------------------------------------------------------------------------------
resource "aws_route53_record" "server_A" {
  for_each = var.hostname_ip_map

  zone_id = var.zone_id
  name    = each.key
  type    = "A"
  ttl     = var.ttl
  records = [
    each.value,
  ]
}

resource "aws_route53_record" "server_PTR" {
  for_each = var.hostname_ip_map

  zone_id = var.reverse_zone_id
  name = format(
    "%s.%s.%s.%s.in-addr.arpa.",
    element(split(".", each.value), 3),
    element(split(".", each.value), 2),
    element(split(".", each.value), 1),
    element(split(".", each.value), 0),
  )
  type = "PTR"
  ttl  = var.ttl
  records = [
    each.key,
  ]
}

resource "aws_route53_record" "ca_A" {
  zone_id = var.zone_id
  name    = "ipa-ca.${var.domain}"
  type    = "A"
  ttl     = var.ttl
  records = values(var.hostname_ip_map)
}

resource "aws_route53_record" "kerberos_TXT" {
  zone_id = var.zone_id
  name    = "_kerberos.${var.domain}"
  type    = "TXT"
  ttl     = var.ttl
  records = [
    upper(var.domain),
  ]
}

resource "aws_route53_record" "master_SRV" {
  for_each = local.tcp_and_udp

  zone_id = var.zone_id
  name    = "_kerberos-master._${each.value}.${var.domain}"
  type    = "SRV"
  ttl     = var.ttl
  records = [
    for hostname, ip in var.hostname_ip_map :
    "0 100 88 ${hostname}"
  ]
}

resource "aws_route53_record" "server_SRV" {
  for_each = local.tcp_and_udp

  zone_id = var.zone_id
  name    = "_kerberos._${each.value}.${var.domain}"
  type    = "SRV"
  ttl     = var.ttl
  records = [
    for hostname, ip in var.hostname_ip_map :
    "0 100 88 ${hostname}"
  ]
}

resource "aws_route53_record" "password_SRV" {
  for_each = local.tcp_and_udp

  zone_id = var.zone_id
  name    = "_kpasswd._${each.value}.${var.domain}"
  type    = "SRV"
  ttl     = var.ttl
  records = [
    for hostname, ip in var.hostname_ip_map :
    "0 100 464 ${hostname}"
  ]
}

resource "aws_route53_record" "ldap_SRV" {
  zone_id = var.zone_id
  name    = "_ldap._tcp.${var.domain}"
  type    = "SRV"
  ttl     = var.ttl
  records = [
    for hostname, ip in var.hostname_ip_map :
    "0 100 389 ${hostname}"
  ]
}

resource "aws_route53_record" "ldaps_SRV" {
  zone_id = var.zone_id
  name    = "_ldaps._tcp.${var.domain}"
  type    = "SRV"
  ttl     = var.ttl
  records = [
    for hostname, ip in var.hostname_ip_map :
    "0 100 636 ${hostname}"
  ]
}

#-------------------------------------------------------------------------------
# Create all necessary DNS records for the IPA cluster.
# -------------------------------------------------------------------------------
resource "aws_route53_record" "server_A" {
  alias {
    name                   = var.load_balancer_dns_name
    zone_id                = var.load_balancer_zone_id
    evaluate_target_health = true
  }
  name    = "${var.hostname}.${var.domain}"
  type    = "A"
  zone_id = var.zone_id
}

resource "aws_route53_record" "ca_A" {
  alias {
    name                   = var.load_balancer_dns_name
    zone_id                = var.load_balancer_zone_id
    evaluate_target_health = true
  }
  name    = "${var.hostname}-ca.${var.domain}"
  type    = "A"
  zone_id = var.zone_id
}

resource "aws_route53_record" "kerberos_TXT" {
  name = "_kerberos.${var.domain}"
  ttl  = var.ttl
  type = "TXT"
  records = [
    upper(var.domain),
  ]
  zone_id = var.zone_id
}

resource "aws_route53_record" "master_SRV" {
  for_each = local.tcp_and_udp

  name    = "_kerberos-master._${each.value}.${var.domain}"
  records = ["0 100 88 ${var.hostname}.${var.domain}"]
  type    = "SRV"
  ttl     = var.ttl
  zone_id = var.zone_id
}

resource "aws_route53_record" "server_SRV" {
  for_each = local.tcp_and_udp

  name    = "_kerberos._${each.value}.${var.domain}"
  records = ["0 100 88 ${var.hostname}.${var.domain}"]
  type    = "SRV"
  ttl     = var.ttl
  zone_id = var.zone_id
}

resource "aws_route53_record" "password_SRV" {
  for_each = local.tcp_and_udp

  name    = "_kpasswd._${each.value}.${var.domain}"
  records = ["0 100 464 ${var.hostname}.${var.domain}"]
  type    = "SRV"
  ttl     = var.ttl
  zone_id = var.zone_id
}

resource "aws_route53_record" "ldap_SRV" {
  name    = "_ldap._tcp.${var.domain}"
  records = ["0 100 389 ${var.hostname}.${var.domain}"]
  type    = "SRV"
  ttl     = var.ttl
  zone_id = var.zone_id
}

resource "aws_route53_record" "ldaps_SRV" {
  name    = "_ldaps._tcp.${var.domain}"
  records = ["0 100 636 ${var.hostname}.${var.domain}"]
  type    = "SRV"
  ttl     = var.ttl
  zone_id = var.zone_id
}

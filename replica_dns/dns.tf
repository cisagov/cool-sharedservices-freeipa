#-------------------------------------------------------------------------------
# Create A and PTR DNS records for a replica IPA server.
#-------------------------------------------------------------------------------
resource "aws_route53_record" "server_A" {
  zone_id = var.zone_id
  name    = var.hostname
  type    = "A"
  ttl     = var.ttl
  records = [
    var.ip,
  ]
}

resource "aws_route53_record" "ptr" {
  zone_id = var.reverse_zone_id
  name = format(
    "%s.%s.%s.%s.in-addr.arpa.",
    element(split(".", var.ip), 3),
    element(split(".", var.ip), 2),
    element(split(".", var.ip), 1),
    element(split(".", var.ip), 0),
  )
  type = "PTR"
  ttl  = var.ttl
  records = [
    var.hostname
  ]
}

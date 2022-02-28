#-------------------------------------------------------------------------------
# Create the ACM certificate used by the FreeIPA cluster.
#-------------------------------------------------------------------------------

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

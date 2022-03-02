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
    # See here for an explanation as to why we specify this lifecycle
    # attribute:
    # https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/acm_certificate
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
  # These are just records that are put in place so that ACM can
  # verify we own the domain. If var.ttl is set to a large value
  # because we don't expect the FreeIPA-specific DNS records to
  # change, we would still want these records to have a low TTL so
  # that redeployments can happen in a timely manner.  Therefore we do
  # not use var.ttl here.
  ttl     = 60
  type    = each.value.type
  zone_id = data.terraform_remote_state.public_dns.outputs.cyber_dhs_gov_zone.id
}

resource "aws_acm_certificate_validation" "ipa" {
  provider = aws.sharedservicesprovisionaccount

  certificate_arn         = aws_acm_certificate.ipa.arn
  validation_record_fqdns = [for record in aws_route53_record.ipa_cert_validation : record.fqdn]
}

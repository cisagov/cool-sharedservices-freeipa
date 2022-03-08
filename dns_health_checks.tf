#-------------------------------------------------------------------------------
# Create Route53 health checks for the IPA servers.
# -------------------------------------------------------------------------------

resource "aws_route53_health_check" "system_status_check" {
  for_each = {
    "${module.ipa0.server.id}" = { hostname = "ipa0", server = module.ipa0.server }
    "${module.ipa1.server.id}" = { hostname = "ipa1", server = module.ipa1.server }
    "${module.ipa2.server.id}" = { hostname = "ipa2", server = module.ipa2.server }
  }
  provider = aws.sharedservicesprovisionaccount

  cloudwatch_alarm_name           = module.cw_alarms_ipa.system_status_check[each.key].alarm_name
  cloudwatch_alarm_region         = var.aws_region
  insufficient_data_health_status = "Unhealthy"
  reference_name                  = each.value.hostname
  type                            = "CLOUDWATCH_METRIC"
}

resource "aws_route53_health_check" "instance_status_check" {
  for_each = {
    "${module.ipa0.server.id}" = { hostname = "ipa0", server = module.ipa0.server }
    "${module.ipa1.server.id}" = { hostname = "ipa1", server = module.ipa1.server }
    "${module.ipa2.server.id}" = { hostname = "ipa2", server = module.ipa2.server }
  }
  provider = aws.sharedservicesprovisionaccount

  cloudwatch_alarm_name           = module.cw_alarms_ipa.instance_status_check[each.key].alarm_name
  cloudwatch_alarm_region         = var.aws_region
  insufficient_data_health_status = "Unhealthy"
  reference_name                  = each.value.hostname
  type                            = "CLOUDWATCH_METRIC"
}

# This is a calculated health check that requires all the child health
# checks to pass before allowing the instance to be considered as
# healthy.
resource "aws_route53_health_check" "overall" {
  for_each = {
    "${module.ipa0.server.id}" = { hostname = "ipa0", server = module.ipa0.server }
    "${module.ipa1.server.id}" = { hostname = "ipa1", server = module.ipa1.server }
    "${module.ipa2.server.id}" = { hostname = "ipa2", server = module.ipa2.server }
  }
  provider = aws.sharedservicesprovisionaccount

  child_health_threshold = 2
  child_healthchecks = [
    aws_route53_health_check.instance_status_check[each.key].id,
    aws_route53_health_check.system_status_check[each.key].id,
  ]
  reference_name = each.value.hostname
  type           = "CALCULATED"
}

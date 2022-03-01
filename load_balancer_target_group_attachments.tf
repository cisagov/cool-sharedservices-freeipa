#-------------------------------------------------------------------------------
# Create the load balancer target group attachments.
#-------------------------------------------------------------------------------

locals {
  # A merge of all NLB target groups, whether TLS or not.
  nlb_target_groups = merge(aws_lb_target_group.nlb_not_tls, aws_lb_target_group.nlb_tls)

  # All NLB target groups that target the ALB (HTTP and HTTPS only).
  nlb_target_groups_to_alb = { for key, value in local.nlb_target_groups : key => value if contains([80, 443], value.port) }

  # All NLB target groups that target the instances directly
  # (everything except HTTP and HTTPS).
  nlb_target_groups_to_instances = { for key, value in local.nlb_target_groups : key => value if !contains([80, 443], value.port) }

  # Now construct a map that contains every possible combination of a
  # value from nlb_target_groups_to_instances and a value from
  # module.ipa.
  nlb_target_group_and_ipa_product_keys = setproduct(keys(local.nlb_target_groups_to_instances), keys(module.ipa))
  nlb_target_group_and_ipa_product      = { for k in local.nlb_target_group_and_ipa_product_keys : join("", k) => merge(local.nlb_target_groups_to_instances[k[0]], { ipa_server : module.ipa[k[1]] }) }
}

# FreeIPA network load balancer target group attachments
#
# HTTP and HTTPS gets sent to the ALB, while everything else gets sent
# directly to the IPA instances.
resource "aws_lb_target_group_attachment" "nlb_alb" {
  for_each = local.nlb_target_groups_to_alb
  provider = aws.sharedservicesprovisionaccount

  port             = each.value.port
  target_group_arn = each.value.arn
  target_id        = aws_lb.alb.id
}
resource "aws_lb_target_group_attachment" "nlb_ipa" {
  for_each = local.nlb_target_group_and_ipa_product
  provider = aws.sharedservicesprovisionaccount

  port             = each.value.port
  target_group_arn = each.value.arn
  target_id        = each.value.ipa_server.server.id
}

# FreeIPA application load balancer target group attachments
resource "aws_lb_target_group_attachment" "alb_http" {
  for_each = module.ipa
  provider = aws.sharedservicesprovisionaccount

  port             = 80
  target_group_arn = aws_lb_target_group.alb_http.arn
  target_id        = each.value.server.id
}
resource "aws_lb_target_group_attachment" "alb_https" {
  for_each = module.ipa
  provider = aws.sharedservicesprovisionaccount

  port             = 443
  target_group_arn = aws_lb_target_group.alb_https.arn
  target_id        = each.value.server.id
}

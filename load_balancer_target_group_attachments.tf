#-------------------------------------------------------------------------------
# Create the load balancer target group attachments.
#-------------------------------------------------------------------------------

# FreeIPA network load balancer target group attachments
#
# HTTP and HTTPS gets sent to the ALB, while everything else gets sent
# directly to the IPA instances.
resource "aws_lb_target_group_attachment" "nlb_alb" {
  for_each = { for key, value in aws_lb_target_group.nlb_not_tls : key => value if contains([80, 443], value.port) }
  provider = aws.sharedservicesprovisionaccount

  port             = each.value.port
  target_group_arn = each.value.arn
  target_id        = aws_lb.alb.id
}
resource "aws_lb_target_group_attachment" "nlb_not_tls_ipa0" {
  for_each = { for key, value in aws_lb_target_group.nlb_not_tls : key => value if !contains([80, 443], value.port) }
  provider = aws.sharedservicesprovisionaccount

  port             = each.value.port
  target_group_arn = each.value.arn
  target_id        = module.ipa0.server.id
}
resource "aws_lb_target_group_attachment" "nlb_tls_ipa0" {
  for_each = { for key, value in aws_lb_target_group.nlb_tls : key => value if !contains([80, 443], value.port) }
  provider = aws.sharedservicesprovisionaccount

  port             = each.value.port
  target_group_arn = each.value.arn
  target_id        = module.ipa0.server.id
}
resource "aws_lb_target_group_attachment" "nlb_not_tls_ipa1" {
  for_each = { for key, value in aws_lb_target_group.nlb_not_tls : key => value if !contains([80, 443], value.port) }
  provider = aws.sharedservicesprovisionaccount

  port             = each.value.port
  target_group_arn = each.value.arn
  target_id        = module.ipa1.server.id
}
resource "aws_lb_target_group_attachment" "nlb_tls_ipa1" {
  for_each = { for key, value in aws_lb_target_group.nlb_tls : key => value if !contains([80, 443], value.port) }
  provider = aws.sharedservicesprovisionaccount

  port             = each.value.port
  target_group_arn = each.value.arn
  target_id        = module.ipa1.server.id
}
resource "aws_lb_target_group_attachment" "nlb_not_tls_ipa2" {
  for_each = { for key, value in aws_lb_target_group.nlb_not_tls : key => value if !contains([80, 443], value.port) }
  provider = aws.sharedservicesprovisionaccount

  port             = each.value.port
  target_group_arn = each.value.arn
  target_id        = module.ipa2.server.id
}
resource "aws_lb_target_group_attachment" "nlb_tls_ipa2" {
  for_each = { for key, value in aws_lb_target_group.nlb_tls : key => value if !contains([80, 443], value.port) }
  provider = aws.sharedservicesprovisionaccount

  port             = each.value.port
  target_group_arn = each.value.arn
  target_id        = module.ipa2.server.id
}

# FreeIPA application load balancer target group attachments
resource "aws_lb_target_group_attachment" "alb_http_0" {
  provider = aws.sharedservicesprovisionaccount

  port             = 80
  target_group_arn = aws_lb_target_group.alb_http.arn
  target_id        = module.ipa0.server.id
}
resource "aws_lb_target_group_attachment" "alb_http_1" {
  provider = aws.sharedservicesprovisionaccount

  port             = 80
  target_group_arn = aws_lb_target_group.alb_http.arn
  target_id        = module.ipa1.server.id
}
resource "aws_lb_target_group_attachment" "alb_http_2" {
  provider = aws.sharedservicesprovisionaccount

  port             = 80
  target_group_arn = aws_lb_target_group.alb_http.arn
  target_id        = module.ipa2.server.id
}
resource "aws_lb_target_group_attachment" "alb_https_0" {
  provider = aws.sharedservicesprovisionaccount

  port             = 443
  target_group_arn = aws_lb_target_group.alb_https.arn
  target_id        = module.ipa0.server.id
}
resource "aws_lb_target_group_attachment" "alb_https_1" {
  provider = aws.sharedservicesprovisionaccount

  port             = 443
  target_group_arn = aws_lb_target_group.alb_https.arn
  target_id        = module.ipa1.server.id
}
resource "aws_lb_target_group_attachment" "alb_https_2" {
  provider = aws.sharedservicesprovisionaccount

  port             = 443
  target_group_arn = aws_lb_target_group.alb_https.arn
  target_id        = module.ipa2.server.id
}

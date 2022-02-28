#-------------------------------------------------------------------------------
# Create the FreeIPA load balancer listeners.
#-------------------------------------------------------------------------------

# FreeIPA network load balancer listeners
resource "aws_lb_listener" "nlb_not_tls" {
  for_each = aws_lb_target_group.nlb_not_tls
  provider = aws.sharedservicesprovisionaccount

  load_balancer_arn = aws_lb.nlb.arn
  port              = each.value.port
  protocol          = each.value.protocol

  default_action {
    target_group_arn = each.value.arn
    type             = "forward"
  }
}
resource "aws_lb_listener" "nlb_tls" {
  depends_on = [
    aws_acm_certificate_validation.ipa,
  ]
  for_each = aws_lb_target_group.nlb_tls
  provider = aws.sharedservicesprovisionaccount

  load_balancer_arn = aws_lb.nlb.arn
  port              = each.value.port
  protocol          = each.value.protocol
  ssl_policy        = "ELBSecurityPolicy-TLS13-1-2-2021-06"
  certificate_arn   = aws_acm_certificate.ipa.arn

  default_action {
    target_group_arn = each.value.arn
    type             = "forward"
  }
}

# FreeIPA application load balancer listeners
resource "aws_lb_listener" "alb_http" {
  provider = aws.sharedservicesprovisionaccount

  load_balancer_arn = aws_lb.alb.arn
  port              = 80
  protocol          = "HTTP"

  default_action {
    target_group_arn = aws_lb_target_group.alb_http.arn
    type             = "forward"
  }
}
resource "aws_lb_listener" "alb_https" {
  depends_on = [
    aws_acm_certificate_validation.ipa,
  ]
  provider = aws.sharedservicesprovisionaccount

  load_balancer_arn = aws_lb.alb.arn
  port              = 443
  protocol          = "HTTPS"
  ssl_policy        = "ELBSecurityPolicy-TLS-1-2-2017-01"
  certificate_arn   = aws_acm_certificate.ipa.arn

  default_action {
    target_group_arn = aws_lb_target_group.alb_https.arn
    type             = "forward"
  }
}

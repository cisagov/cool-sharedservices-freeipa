# Security group for IPA servers
resource "aws_security_group" "server" {
  vpc_id = var.vpc_id

  description = "Security group for IPA servers"
}

# Allow HTTP out anywhere.  This is necessary to retrieve updated
# antivirus signatures for ClamAV via freshclam.
resource "aws_security_group_rule" "server_http_egress" {
  security_group_id = aws_security_group.server.id
  type              = "egress"
  protocol          = "tcp"
  cidr_blocks       = ["0.0.0.0/0"]
  from_port         = 80
  to_port           = 80
}
# Allow HTTPS out anywhere.  This is necessary for access to AWS
# services via the HTTPS interface.
resource "aws_security_group_rule" "server_https_egress" {
  security_group_id = aws_security_group.server.id
  type              = "egress"
  protocol          = "tcp"
  cidr_blocks       = ["0.0.0.0/0"]
  from_port         = 443
  to_port           = 443
}

# Ingress rules for IPA
resource "aws_security_group_rule" "server_ingress_trusted" {
  for_each = local.ipa_ports

  security_group_id = aws_security_group.server.id
  type              = "ingress"
  protocol          = each.value.proto
  cidr_blocks       = var.trusted_cidr_blocks
  from_port         = each.value.port
  to_port           = each.value.port
}
resource "aws_security_group_rule" "server_ingress_self" {
  for_each = local.ipa_ports

  security_group_id = aws_security_group.server.id
  type              = "ingress"
  protocol          = each.value.proto
  self              = true
  from_port         = each.value.port
  to_port           = each.value.port
}
resource "aws_security_group_rule" "server_ingress_clients" {
  for_each = local.ipa_ports

  security_group_id        = aws_security_group.server.id
  type                     = "ingress"
  protocol                 = each.value.proto
  source_security_group_id = aws_security_group.client.id
  from_port                = each.value.port
  to_port                  = each.value.port
}
resource "aws_security_group_rule" "server_ingress_load_balancer" {
  for_each = local.ipa_ports

  security_group_id = aws_security_group.server.id
  type              = "ingress"
  protocol          = each.value.proto
  cidr_blocks       = [for ip in var.load_balancer_ips : format("%s/32", ip)]
  from_port         = each.value.port
  to_port           = each.value.port
}

# Egress rules for IPA
resource "aws_security_group_rule" "server_egress_self" {
  for_each = local.ipa_ports

  security_group_id = aws_security_group.server.id
  type              = "egress"
  protocol          = each.value.proto
  self              = true
  from_port         = each.value.port
  to_port           = each.value.port
}

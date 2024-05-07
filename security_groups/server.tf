# Security group for IPA servers
resource "aws_security_group" "server" {
  vpc_id = var.vpc_id

  description = "Security group for IPA servers"
}

# Allow HTTP out anywhere.  This is necessary to retrieve updated
# antivirus signatures for ClamAV via freshclam.
resource "aws_security_group_rule" "server_http_egress" {
  cidr_blocks       = ["0.0.0.0/0"]
  from_port         = 80
  protocol          = "tcp"
  security_group_id = aws_security_group.server.id
  to_port           = 80
  type              = "egress"
}
# Allow HTTPS out anywhere.  This is necessary for access to AWS
# services via the HTTPS interface.
resource "aws_security_group_rule" "server_https_egress" {
  cidr_blocks       = ["0.0.0.0/0"]
  from_port         = 443
  protocol          = "tcp"
  security_group_id = aws_security_group.server.id
  to_port           = 443
  type              = "egress"
}

# Ingress rules for IPA
resource "aws_security_group_rule" "server_ingress_trusted" {
  for_each = local.ipa_ports

  cidr_blocks       = var.trusted_cidr_blocks
  from_port         = each.value.port
  protocol          = each.value.proto
  security_group_id = aws_security_group.server.id
  to_port           = each.value.port
  type              = "ingress"
}
resource "aws_security_group_rule" "server_ingress_self" {
  for_each = local.ipa_ports

  from_port         = each.value.port
  protocol          = each.value.proto
  security_group_id = aws_security_group.server.id
  self              = true
  to_port           = each.value.port
  type              = "ingress"
}
resource "aws_security_group_rule" "server_ingress_clients" {
  for_each = local.ipa_ports

  from_port                = each.value.port
  protocol                 = each.value.proto
  security_group_id        = aws_security_group.server.id
  source_security_group_id = aws_security_group.client.id
  to_port                  = each.value.port
  type                     = "ingress"
}

# Egress rules for IPA
resource "aws_security_group_rule" "server_egress_self" {
  for_each = local.ipa_ports

  from_port         = each.value.port
  protocol          = each.value.proto
  security_group_id = aws_security_group.server.id
  self              = true
  to_port           = each.value.port
  type              = "egress"
}

# Security group for IPA clients
resource "aws_security_group" "client" {
  vpc_id = var.vpc_id

  description = "Security group for IPA clients"
  tags        = var.tags
}

# Egress rules
resource "aws_security_group_rule" "client_egress" {
  for_each = local.ipa_ports

  security_group_id        = aws_security_group.client.id
  type                     = "egress"
  protocol                 = each.value.proto
  source_security_group_id = aws_security_group.server.id
  from_port                = each.value.port
  to_port                  = each.value.port
}

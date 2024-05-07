# Security group for IPA clients
resource "aws_security_group" "client" {
  vpc_id = var.vpc_id

  description = "Security group for IPA clients"
}

# Egress rules
resource "aws_security_group_rule" "client_egress" {
  for_each = local.ipa_ports

  from_port                = each.value.port
  protocol                 = each.value.proto
  security_group_id        = aws_security_group.client.id
  source_security_group_id = aws_security_group.server.id
  to_port                  = each.value.port
  type                     = "egress"
}

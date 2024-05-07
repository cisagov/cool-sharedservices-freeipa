output "client" {
  description = "The IPA client security group."
  value       = aws_security_group.client
}

output "server" {
  description = "The IPA server security group."
  value       = aws_security_group.server
}

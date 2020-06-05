output "client" {
  value       = aws_security_group.client
  description = "The IPA client security group."
}

output "server" {
  value       = aws_security_group.server
  description = "The IPA server security group."
}

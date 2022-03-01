output "client_security_group" {
  value       = module.security_groups.client
  description = "The IPA client security group."
}

output "server_security_group" {
  value       = module.security_groups.server
  description = "The IPA server security group."
}

output "servers" {
  value       = [for ipa in module.ipa : ipa.server]
  description = "The IPA server EC2 instances."
}

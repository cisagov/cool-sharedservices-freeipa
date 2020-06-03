output "client_security_group" {
  value       = module.security_groups.client
  description = "The IPA client security group."
}

output "server_security_group" {
  value       = module.security_groups.server
  description = "The IPA server security group."
}

output "server0" {
  value       = module.ipa0.server
  description = "The first IPA server EC2 instance."
}

output "server1" {
  value       = module.ipa1.server
  description = "The second IPA server EC2 instance."
}

output "server2" {
  value       = module.ipa2.server
  description = "The third IPA server EC2 instance."
}

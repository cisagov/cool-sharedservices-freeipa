output "client_security_group" {
  description = "The IPA client security group."
  value       = module.security_groups.client
}

output "server_security_group" {
  description = "The IPA server security group."
  value       = module.security_groups.server
}

output "server0" {
  description = "The first IPA server EC2 instance."
  value       = module.ipa0.server
}

output "server1" {
  description = "The second IPA server EC2 instance."
  value       = module.ipa1.server
}

output "server2" {
  description = "The third IPA server EC2 instance."
  value       = module.ipa2.server
}

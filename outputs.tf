output "client_security_group" {
  value       = module.ipa_master.client_security_group
  description = "The IPA client security group."
}

output "server0" {
  value       = module.ipa_master.server
  description = "The first IPA server EC2 instance."
}

# output "replica1" {
#   value       = module.ipa_replica1.replica
#   description = "The first IPA replica EC2 instance."
# }

# output "replica2" {
#   value       = module.ipa_replica2.replica
#   description = "The second IPA replica EC2 instance."
# }

output "server_security_group" {
  value       = module.ipa_master.server_security_group
  description = "The IPA server security group."
}

output "client_security_group" {
  value       = module.ipa_master.client_security_group
  description = "The IPA client security group."
}

output "master" {
  value       = module.ipa_master.master
  description = "The IPA master EC2 instance."
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

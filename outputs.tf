output "client_security_group_id" {
  value       = module.ipa_master.client_security_group_id
  description = "The ID corresponding to the IPA client security group."
}

output "master_certificate_read_role_arn" {
  value       = module.certreadrole_ipa_master.arn
  description = "The ARN corresponding to the role used by the IPA master to read its certificate information."
}

output "master_id" {
  value       = module.ipa_master.id
  description = "The EC2 instance ID corresponding to the IPA master."
}

output "replica1_certificate_read_role_arn" {
  value       = module.certreadrole_ipa_replica1.arn
  description = "The ARN corresponding to the role used by the first IPA replica to read its certificate information."
}

output "replica1_id" {
  value       = module.ipa_replica1.id
  description = "The EC2 instance ID corresponding to the first IPA replica."
}

output "replica2_certificate_read_role_arn" {
  value       = module.certreadrole_ipa_replica2.arn
  description = "The ARN corresponding to the role used by the second IPA replica to read its certificate information."
}

output "replica2_id" {
  value       = module.ipa_replica2.id
  description = "The EC2 instance ID corresponding to the second IPA replica."
}

output "server_security_group_id" {
  value       = module.ipa_master.server_security_group_id
  description = "The ID corresponding to the IPA server security group."
}

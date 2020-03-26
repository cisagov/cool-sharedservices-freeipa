#-------------------------------------------------------------------------------
# Configure the master and replica modules.
#-------------------------------------------------------------------------------

locals {
  # Get Shared Services account ID from the default provider
  this_account_id = data.aws_caller_identity.sharedservices.account_id

  # Look up Shared Services account name from AWS organizations
  # provider
  this_account_name = [
    for account in data.aws_organizations_organization.cool.accounts :
    account.name
    if account.id == local.this_account_id
  ][0]

  # Determine Shared Services account type based on account name.
  #
  # The account name format is "ACCOUNT_NAME (ACCOUNT_TYPE)" - for
  # example, "Shared Services (Production)".
  this_account_type = length(regexall("\\(([^()]*)\\)", local.this_account_name)) == 1 ? regex("\\(([^()]*)\\)", local.this_account_name)[0] : "Unknown"

  # Determine the ID of the corresponding Images account
  images_account_id = [
    for account in data.aws_organizations_organization.cool.accounts :
    account.id
    if account.name == "Images (${local.this_account_type})"
  ][0]

  # The subnets where the master and two replicas are to be placed
  master_subnet_cidr   = keys(data.terraform_remote_state.networking.outputs.private_subnets)[0]
  replica1_subnet_cidr = keys(data.terraform_remote_state.networking.outputs.private_subnets)[1]
  replica2_subnet_cidr = keys(data.terraform_remote_state.networking.outputs.private_subnets)[2]
}

module "ipa_master" {
  source = "github.com/cisagov/freeipa-master-tf-module"

  providers = {
    aws            = aws
    aws.public_dns = aws.public_dns
  }

  admin_pw                    = var.admin_pw
  ami_owner_account_id        = local.images_account_id
  associate_public_ip_address = false
  cert_bucket_name            = var.cert_bucket_name
  cert_pw                     = var.master_cert_pw
  cert_read_role_arn          = module.certreadrole_ipa_master.role.arn
  directory_service_pw        = var.directory_service_pw
  domain                      = var.cool_domain
  hostname                    = "ipa.${var.cool_domain}"
  private_reverse_zone_id     = data.terraform_remote_state.networking.outputs.private_subnet_private_reverse_zones[local.master_subnet_cidr].id
  private_zone_id             = data.terraform_remote_state.networking.outputs.private_zone.id
  realm                       = upper(var.cool_domain)
  subnet_id                   = data.terraform_remote_state.networking.outputs.private_subnets[local.master_subnet_cidr].id
  tags                        = var.tags
  trusted_cidr_blocks         = var.trusted_cidr_blocks
}

module "ipa_replica1" {
  source = "github.com/cisagov/freeipa-replica-tf-module"

  providers = {
    aws            = aws
    aws.public_dns = aws.public_dns
  }

  admin_pw                    = var.admin_pw
  ami_owner_account_id        = local.images_account_id
  associate_public_ip_address = false
  cert_bucket_name            = var.cert_bucket_name
  cert_pw                     = var.replica1_cert_pw
  cert_read_role_arn          = module.certreadrole_ipa_replica1.role.arn
  hostname                    = "ipa-replica1.${var.cool_domain}"
  master_hostname             = "ipa.${var.cool_domain}"
  private_reverse_zone_id     = data.terraform_remote_state.networking.outputs.private_subnet_private_reverse_zones[local.replica1_subnet_cidr].id
  private_zone_id             = data.terraform_remote_state.networking.outputs.private_zone.id
  server_security_group_id    = module.ipa_master.server_security_group.id
  subnet_id                   = data.terraform_remote_state.networking.outputs.private_subnets[local.replica1_subnet_cidr].id
  tags                        = var.tags
}

module "ipa_replica2" {
  source = "github.com/cisagov/freeipa-replica-tf-module"

  providers = {
    aws            = aws
    aws.public_dns = aws.public_dns
  }

  admin_pw                    = var.admin_pw
  ami_owner_account_id        = local.images_account_id
  associate_public_ip_address = false
  cert_bucket_name            = var.cert_bucket_name
  cert_pw                     = var.replica2_cert_pw
  cert_read_role_arn          = module.certreadrole_ipa_replica2.role.arn
  hostname                    = "ipa-replica2.${var.cool_domain}"
  master_hostname             = "ipa.${var.cool_domain}"
  private_reverse_zone_id     = data.terraform_remote_state.networking.outputs.private_subnet_private_reverse_zones[local.replica2_subnet_cidr].id
  private_zone_id             = data.terraform_remote_state.networking.outputs.private_zone.id
  server_security_group_id    = module.ipa_master.server_security_group.id
  subnet_id                   = data.terraform_remote_state.networking.outputs.private_subnets[local.replica2_subnet_cidr].id
  tags                        = var.tags
}

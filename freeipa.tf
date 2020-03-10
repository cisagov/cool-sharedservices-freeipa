#-------------------------------------------------------------------------------
# Configure the master and replica modules.
#-------------------------------------------------------------------------------

locals {
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
  ami_owner_account_id        = "207871073513" # The COOL Images account
  associate_public_ip_address = true
  cert_bucket_name            = var.cert_bucket_name
  cert_pw                     = var.master_cert_pw
  cert_read_role_arn          = module.certreadrole_ipa_master.role.arn
  directory_service_pw        = var.directory_service_pw
  domain                      = var.cool_domain
  hostname                    = "ipa.${var.cool_domain}"
  private_reverse_zone_id     = data.terraform_remote_state.networking.outputs.private_subnet_private_reverse_zones[local.master_subnet_cidr].id
  private_zone_id             = data.terraform_remote_state.networking.outputs.private_zone.id
  public_zone_id              = data.aws_route53_zone.public_zone.zone_id
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
  ami_owner_account_id        = "207871073513" # The COOL Images account
  associate_public_ip_address = true
  cert_bucket_name            = var.cert_bucket_name
  cert_pw                     = var.replica1_cert_pw
  cert_read_role_arn          = module.certreadrole_ipa_replica1.role.arn
  hostname                    = "ipa-replica1.${var.cool_domain}"
  master_hostname             = "ipa.${var.cool_domain}"
  private_reverse_zone_id     = data.terraform_remote_state.networking.outputs.private_subnet_private_reverse_zones[local.replica1_subnet_cidr].id
  private_zone_id             = data.terraform_remote_state.networking.outputs.private_zone.id
  public_zone_id              = data.aws_route53_zone.public_zone.zone_id
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
  ami_owner_account_id        = "207871073513" # The COOL Images account
  associate_public_ip_address = true
  cert_bucket_name            = var.cert_bucket_name
  cert_pw                     = var.replica2_cert_pw
  cert_read_role_arn          = module.certreadrole_ipa_replica2.role.arn
  hostname                    = "ipa-replica2.${var.cool_domain}"
  master_hostname             = "ipa.${var.cool_domain}"
  private_reverse_zone_id     = data.terraform_remote_state.networking.outputs.private_subnet_private_reverse_zones[local.replica2_subnet_cidr].id
  private_zone_id             = data.terraform_remote_state.networking.outputs.private_zone.id
  public_zone_id              = data.aws_route53_zone.public_zone.zone_id
  server_security_group_id    = module.ipa_master.server_security_group.id
  subnet_id                   = data.terraform_remote_state.networking.outputs.private_subnets[local.replica2_subnet_cidr].id
  tags                        = var.tags
}

#-------------------------------------------------------------------------------
# Configure the master and replica modules.
#-------------------------------------------------------------------------------
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
  private_reverse_zone_id     = var.master_private_reverse_zone_id
  private_zone_id             = var.private_zone_id
  public_zone_id              = data.aws_route53_zone.public_zone.zone_id
  realm                       = upper(var.cool_domain)
  subnet_id                   = var.master_subnet_id
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
  private_reverse_zone_id     = var.replica1_private_reverse_zone_id
  private_zone_id             = var.private_zone_id
  public_zone_id              = data.aws_route53_zone.public_zone.zone_id
  server_security_group_id    = module.ipa_master.server_security_group.id
  subnet_id                   = var.replica1_subnet_id
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
  private_reverse_zone_id     = var.replica2_private_reverse_zone_id
  private_zone_id             = var.private_zone_id
  public_zone_id              = data.aws_route53_zone.public_zone.zone_id
  server_security_group_id    = module.ipa_master.server_security_group.id
  subnet_id                   = var.replica2_subnet_id
  tags                        = var.tags
}

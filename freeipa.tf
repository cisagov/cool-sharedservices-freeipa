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

  # The subnets where the IPA servers are to be placed
  subnet_cidrs = keys(data.terraform_remote_state.networking.outputs.private_subnets)

  # The IP addresses of the IPA servers.  AWS reserves the first four
  # and the last IP address in each subnet.
  #
  # The latest version of cisagov/freeipa-server-tf-module requires us
  # to assign IPs in order to break the dependency of DNS record
  # resources on the corresponding EC2 instance resources; otherwise,
  # it is not possible to recreate the IPA servers one by one as is
  # required when a new FreeIPA AMI is made available.
  ipa_ips = [for cidr in local.subnet_cidrs : cidrhost(cidr, 4)]
}

# Create the IPA client and server security groups
module "security_groups" {
  source = "./security_groups"

  tags                = var.tags
  trusted_cidr_blocks = var.trusted_cidr_blocks
  vpc_id              = data.terraform_remote_state.networking.outputs.vpc.id
}

# Create the IPA servers
module "ipa0" {
  source = "github.com/cisagov/freeipa-server-tf-module"

  ami_owner_account_id = local.images_account_id
  domain               = var.cool_domain
  hostname             = "ipa0.${var.cool_domain}"
  ip                   = local.ipa_ips[0]
  realm                = upper(var.cool_domain)
  security_group_ids   = [module.security_groups.server.id]
  subnet_id            = data.terraform_remote_state.networking.outputs.private_subnets[local.subnet_cidrs[0]].id
  tags                 = merge(var.tags, map("Name", "FreeIPA 0"))
}
module "ipa1" {
  source = "github.com/cisagov/freeipa-server-tf-module"

  ami_owner_account_id = local.images_account_id
  domain               = var.cool_domain
  hostname             = "ipa1.${var.cool_domain}"
  ip                   = local.ipa_ips[1]
  security_group_ids   = [module.security_groups.server.id]
  subnet_id            = data.terraform_remote_state.networking.outputs.private_subnets[local.subnet_cidrs[1]].id
  tags                 = merge(var.tags, map("Name", "FreeIPA 1"))
}
module "ipa2" {
  source = "github.com/cisagov/freeipa-server-tf-module"

  ami_owner_account_id = local.images_account_id
  domain               = var.cool_domain
  hostname             = "ipa2.${var.cool_domain}"
  ip                   = local.ipa_ips[2]
  security_group_ids   = [module.security_groups.server.id]
  subnet_id            = data.terraform_remote_state.networking.outputs.private_subnets[local.subnet_cidrs[2]].id
  tags                 = merge(var.tags, map("Name", "FreeIPA 2"))
}

# Create the DNS entries for the IPA cluster
module "dns" {
  source = "./dns"

  domain = var.cool_domain
  hosts = {
    "ipa0.${var.cool_domain}" = {
      ip              = local.ipa_ips[0]
      reverse_zone_id = data.terraform_remote_state.networking.outputs.private_subnet_private_reverse_zones[local.subnet_cidrs[0]].id
      advertise       = true
    }
    "ipa1.${var.cool_domain}" = {
      ip              = local.ipa_ips[1]
      reverse_zone_id = data.terraform_remote_state.networking.outputs.private_subnet_private_reverse_zones[local.subnet_cidrs[1]].id
      advertise       = true
    }
    "ipa2.${var.cool_domain}" = {
      ip              = local.ipa_ips[2]
      reverse_zone_id = data.terraform_remote_state.networking.outputs.private_subnet_private_reverse_zones[local.subnet_cidrs[2]].id
      advertise       = true
    }
  }
  ttl     = var.ttl
  zone_id = data.terraform_remote_state.networking.outputs.private_zone.id
}

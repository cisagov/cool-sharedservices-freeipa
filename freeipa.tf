#-------------------------------------------------------------------------------
# Configure the master and replica modules.
#-------------------------------------------------------------------------------

locals {
  # The subnets where the IPA servers are to be placed
  subnet_cidrs = keys(data.terraform_remote_state.networking.outputs.private_subnets)

  # The IP addresses of the IPA servers.  AWS reserves the first four
  # and the last IP address in each subnet.
  #
  # cisagov/freeipa-server-tf-module now requires us to assign IPs in
  # order to break the dependency of DNS record resources on the
  # corresponding EC2 instance resources; otherwise, it is not
  # possible to recreate the IPA servers one by one as is required
  # when a new FreeIPA AMI is made available.
  ipa_ips = [for cidr in local.subnet_cidrs : cidrhost(cidr, 4)]
}

# Create the IPA client and server security groups
module "security_groups" {
  source = "./security_groups"
  providers = {
    aws = aws.sharedservicesprovisionaccount
  }

  trusted_cidr_blocks = var.trusted_cidr_blocks
  vpc_id              = data.terraform_remote_state.networking.outputs.vpc.id
}

# Create the IPA servers
module "ipa0" {
  source = "github.com/cisagov/freeipa-server-tf-module"
  providers = {
    aws                                   = aws.sharedservicesprovisionaccount
    aws.provision_ssm_parameter_read_role = aws.provision_ssm_parameter_read_role
  }

  ami_owner_account_id = local.images_account_id
  domain               = var.cool_domain
  hostname             = "ipa0.${var.cool_domain}"
  ip                   = local.ipa_ips[0]
  nessus_hostname_key  = var.nessus_hostname_key
  nessus_key_key       = var.nessus_key_key
  nessus_port_key      = var.nessus_port_key
  realm                = upper(var.cool_domain)
  security_group_ids = [
    module.security_groups.server.id,
    data.terraform_remote_state.cdm.outputs.cdm_security_group.id,
  ]
  subnet_id = data.terraform_remote_state.networking.outputs.private_subnets[local.subnet_cidrs[0]].id
}
module "ipa1" {
  source = "github.com/cisagov/freeipa-server-tf-module"
  providers = {
    aws                                   = aws.sharedservicesprovisionaccount
    aws.provision_ssm_parameter_read_role = aws.provision_ssm_parameter_read_role
  }

  ami_owner_account_id = local.images_account_id
  domain               = var.cool_domain
  hostname             = "ipa1.${var.cool_domain}"
  ip                   = local.ipa_ips[1]
  nessus_hostname_key  = var.nessus_hostname_key
  nessus_key_key       = var.nessus_key_key
  nessus_port_key      = var.nessus_port_key
  security_group_ids = [
    module.security_groups.server.id,
    data.terraform_remote_state.cdm.outputs.cdm_security_group.id,
  ]
  subnet_id = data.terraform_remote_state.networking.outputs.private_subnets[local.subnet_cidrs[1]].id
}
module "ipa2" {
  source = "github.com/cisagov/freeipa-server-tf-module"
  providers = {
    aws                                   = aws.sharedservicesprovisionaccount
    aws.provision_ssm_parameter_read_role = aws.provision_ssm_parameter_read_role
  }

  ami_owner_account_id = local.images_account_id
  domain               = var.cool_domain
  hostname             = "ipa2.${var.cool_domain}"
  ip                   = local.ipa_ips[2]
  nessus_hostname_key  = var.nessus_hostname_key
  nessus_key_key       = var.nessus_key_key
  nessus_port_key      = var.nessus_port_key
  security_group_ids = [
    module.security_groups.server.id,
    data.terraform_remote_state.cdm.outputs.cdm_security_group.id,
  ]
  subnet_id = data.terraform_remote_state.networking.outputs.private_subnets[local.subnet_cidrs[2]].id
}

# Create the DNS entries for the IPA cluster
module "dns" {
  source = "./dns"
  providers = {
    aws = aws.sharedservicesprovisionaccount
  }

  domain = var.cool_domain
  hosts = {
    "ipa0.${var.cool_domain}" = {
      ip              = local.ipa_ips[0]
      reverse_zone_id = data.terraform_remote_state.networking.outputs.private_subnet_private_reverse_zones[local.subnet_cidrs[0]].id
      advertise       = var.advertise_ipa_servers["ipa0"]
    }
    "ipa1.${var.cool_domain}" = {
      ip              = local.ipa_ips[1]
      reverse_zone_id = data.terraform_remote_state.networking.outputs.private_subnet_private_reverse_zones[local.subnet_cidrs[1]].id
      advertise       = var.advertise_ipa_servers["ipa1"]
    }
    "ipa2.${var.cool_domain}" = {
      ip              = local.ipa_ips[2]
      reverse_zone_id = data.terraform_remote_state.networking.outputs.private_subnet_private_reverse_zones[local.subnet_cidrs[2]].id
      advertise       = var.advertise_ipa_servers["ipa2"]
    }
  }
  ttl     = var.ttl
  zone_id = data.terraform_remote_state.networking.outputs.private_zone.id
}

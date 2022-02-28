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

  load_balancer_ips   = [for i in data.aws_network_interface.nlb : i.private_ip]
  trusted_cidr_blocks = var.trusted_cidr_blocks
  vpc_id              = data.terraform_remote_state.networking.outputs.vpc.id
}

# Create the IPA servers
module "ipa0" {
  source = "github.com/cisagov/freeipa-server-tf-module"
  providers = {
    aws                                   = aws.sharedservicesprovisionaccount_ipa0
    aws.provision_ssm_parameter_read_role = aws.provision_ssm_parameter_read_role
  }

  ami_owner_account_id = local.images_account_id
  domain               = var.cool_domain
  hostname             = "ipa0.${var.cool_domain}"
  ip                   = local.ipa_ips[0]
  nessus_hostname_key  = var.nessus_hostname_key
  nessus_key_key       = var.nessus_key_key
  nessus_port_key      = var.nessus_port_key
  netbios_name         = var.netbios_name
  realm                = upper(var.cool_domain)
  root_disk_size       = var.root_disk_size
  security_group_ids = [
    module.security_groups.server.id,
    data.terraform_remote_state.cdm.outputs.cdm_security_group.id,
  ]
  subnet_id = data.terraform_remote_state.networking.outputs.private_subnets[local.subnet_cidrs[0]].id
}
module "ipa1" {
  source = "github.com/cisagov/freeipa-server-tf-module"
  providers = {
    aws                                   = aws.sharedservicesprovisionaccount_ipa1
    aws.provision_ssm_parameter_read_role = aws.provision_ssm_parameter_read_role
  }

  ami_owner_account_id = local.images_account_id
  domain               = var.cool_domain
  hostname             = "ipa1.${var.cool_domain}"
  ip                   = local.ipa_ips[1]
  nessus_hostname_key  = var.nessus_hostname_key
  nessus_key_key       = var.nessus_key_key
  nessus_port_key      = var.nessus_port_key
  netbios_name         = var.netbios_name
  root_disk_size       = var.root_disk_size
  security_group_ids = [
    module.security_groups.server.id,
    data.terraform_remote_state.cdm.outputs.cdm_security_group.id,
  ]
  subnet_id = data.terraform_remote_state.networking.outputs.private_subnets[local.subnet_cidrs[1]].id
}
module "ipa2" {
  source = "github.com/cisagov/freeipa-server-tf-module"
  providers = {
    aws                                   = aws.sharedservicesprovisionaccount_ipa2
    aws.provision_ssm_parameter_read_role = aws.provision_ssm_parameter_read_role
  }

  ami_owner_account_id = local.images_account_id
  domain               = var.cool_domain
  hostname             = "ipa2.${var.cool_domain}"
  ip                   = local.ipa_ips[2]
  nessus_hostname_key  = var.nessus_hostname_key
  nessus_key_key       = var.nessus_key_key
  nessus_port_key      = var.nessus_port_key
  netbios_name         = var.netbios_name
  root_disk_size       = var.root_disk_size
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

  domain                 = var.cool_domain
  hostname               = "ipa"
  load_balancer_dns_name = aws_lb.nlb.dns_name
  load_balancer_zone_id  = aws_lb.nlb.zone_id
  ttl                    = var.ttl
  zone_id                = data.terraform_remote_state.networking.outputs.private_zone.id
}

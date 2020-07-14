# This is the "default" provider that is used to obtain the caller's
# credentials, which are used to set the session name when assuming roles in
# the other providers.

provider "aws" {
  region = var.aws_region
}

# The provider used to lookup account IDs.  See locals.
provider "aws" {
  alias  = "organizationsreadonly"
  region = var.aws_region
  assume_role {
    role_arn     = data.terraform_remote_state.master.outputs.organizationsreadonly_role.arn
    session_name = local.caller_user_name
  }
}

# This provider isn't used, since we choose not associate public IPs
# with the FreeIPA master and replicas.  We do, however, have to
# provide a valid provider to the Terraform module.
provider "aws" {
  alias  = "public_dns"
  region = var.aws_region
  assume_role {
    role_arn     = data.terraform_remote_state.dns_cyber_dhs_gov.outputs.route53resourcechange_role.arn
    session_name = local.caller_user_name
  }
}

# The provider used to create resources inside the Shared Services account.
provider "aws" {
  alias  = "sharedservicesprovisionaccount"
  region = var.aws_region
  assume_role {
    role_arn     = data.terraform_remote_state.sharedservices.outputs.provisionaccount_role.arn
    session_name = local.caller_user_name
  }
}

#-------------------------------------------------------------------------------
# Create roles that allows the master and replica FreeIPA servers to
# read their certs from S3.
# -------------------------------------------------------------------------------

# Grab the caller identity information for the default provider.  We
# will need the account ID below.
data "aws_caller_identity" "default" {}

module "certreadrole_ipa_master" {
  source = "github.com/cisagov/cert-read-role-tf-module"

  providers = {
    aws = aws.cert_create_read_role
  }

  account_ids = [
    data.aws_caller_identity.default.account_id,
  ]
  cert_bucket_name = var.cert_bucket_name
  hostname         = "ipa.${var.cool_domain}"
}

module "certreadrole_ipa_replica1" {
  source = "github.com/cisagov/cert-read-role-tf-module"

  providers = {
    aws = aws.cert_create_read_role
  }

  account_ids = [
    data.aws_caller_identity.default.account_id,
  ]
  cert_bucket_name = var.cert_bucket_name
  hostname         = "ipa-replica1.${var.cool_domain}"
}

module "certreadrole_ipa_replica2" {
  source = "github.com/cisagov/cert-read-role-tf-module"

  providers = {
    aws = aws.cert_create_read_role
  }

  account_ids = [
    data.aws_caller_identity.default.account_id,
  ]
  cert_bucket_name = var.cert_bucket_name
  hostname         = "ipa-replica2.${var.cool_domain}"
}

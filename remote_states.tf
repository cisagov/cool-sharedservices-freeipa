# ------------------------------------------------------------------------------
# Retrieve state data for other Terraform repositories from a
# Terraform backend. This allows use of the root-level outputs of one
# or more Terraform configurations as input data for this
# configuration.
# ------------------------------------------------------------------------------
data "terraform_remote_state" "dns_cyber_dhs_gov" {
  backend = "s3"

  config = {
    encrypt        = true
    bucket         = "cisa-cool-terraform-state"
    dynamodb_table = "terraform-state-lock"
    profile        = "cool-terraform-backend"
    region         = "us-east-1"
    key            = "cool-dns-cyber.dhs.gov.tfstate"
  }

  workspace = "production"
}

data "terraform_remote_state" "master" {
  backend = "s3"

  config = {
    encrypt        = true
    bucket         = "cisa-cool-terraform-state"
    dynamodb_table = "terraform-state-lock"
    profile        = "cool-terraform-backend"
    region         = "us-east-1"
    key            = "cool-accounts/master.tfstate"
  }

  workspace = "production"
}

data "terraform_remote_state" "networking" {
  backend = "s3"

  config = {
    encrypt        = true
    bucket         = "cisa-cool-terraform-state"
    dynamodb_table = "terraform-state-lock"
    profile        = "cool-terraform-backend"
    region         = "us-east-1"
    key            = "cool-sharedservices-networking/terraform.tfstate"
  }

  workspace = terraform.workspace
}

data "terraform_remote_state" "sharedservices" {
  backend = "s3"

  config = {
    encrypt        = true
    bucket         = "cisa-cool-terraform-state"
    dynamodb_table = "terraform-state-lock"
    profile        = "cool-terraform-backend"
    region         = "us-east-1"
    key            = "cool-accounts/shared_services.tfstate"
  }

  workspace = terraform.workspace
}

data "terraform_remote_state" "cdm" {
  backend = "s3"

  config = {
    encrypt        = true
    bucket         = "cisa-cool-terraform-state"
    dynamodb_table = "terraform-state-lock"
    profile        = "cool-terraform-backend"
    region         = "us-east-1"
    key            = "cool-sharedservices-cdm/terraform.tfstate"
  }

  workspace = terraform.workspace
}

# ------------------------------------------------------------------------------
# Retrieve state data for other Terraform repositories from a
# Terraform backend. This allows use of the root-level outputs of one
# or more Terraform configurations as input data for this
# configuration.
# ------------------------------------------------------------------------------
data "terraform_remote_state" "images_parameterstore" {
  backend = "s3"

  config = {
    bucket         = var.terraform_state_bucket
    dynamodb_table = "terraform-state-lock"
    encrypt        = true
    key            = "cool-images-parameterstore/terraform.tfstate"
    profile        = "cool-terraform-backend"
    region         = "us-east-1"
  }

  workspace = terraform.workspace
}

data "terraform_remote_state" "master" {
  backend = "s3"

  config = {
    bucket         = var.terraform_state_bucket
    dynamodb_table = "terraform-state-lock"
    encrypt        = true
    key            = "cool-accounts/master.tfstate"
    profile        = "cool-terraform-backend"
    region         = "us-east-1"
  }

  workspace = terraform.workspace
}

data "terraform_remote_state" "networking" {
  backend = "s3"

  config = {
    bucket         = var.terraform_state_bucket
    dynamodb_table = "terraform-state-lock"
    encrypt        = true
    key            = "cool-sharedservices-networking/terraform.tfstate"
    profile        = "cool-terraform-backend"
    region         = "us-east-1"
  }

  workspace = terraform.workspace
}

data "terraform_remote_state" "sharedservices" {
  backend = "s3"

  config = {
    bucket         = var.terraform_state_bucket
    dynamodb_table = "terraform-state-lock"
    encrypt        = true
    key            = "cool-accounts/shared_services.tfstate"
    profile        = "cool-terraform-backend"
    region         = "us-east-1"
  }

  workspace = terraform.workspace
}

data "terraform_remote_state" "cdm" {
  backend = "s3"

  config = {
    bucket         = var.terraform_state_bucket
    dynamodb_table = "terraform-state-lock"
    encrypt        = true
    key            = "cool-sharedservices-cdm/terraform.tfstate"
    profile        = "cool-terraform-backend"
    region         = "us-east-1"
  }

  workspace = terraform.workspace
}

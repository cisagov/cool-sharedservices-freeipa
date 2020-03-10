# ------------------------------------------------------------------------------
# Retrieve state data for other Terraform repositories from a
# Terraform backend. This allows use of the root-level outputs of one
# or more Terraform configurations as input data for this
# configuration.
# ------------------------------------------------------------------------------
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

  workspace = "production"
}

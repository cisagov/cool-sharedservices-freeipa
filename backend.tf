terraform {
  backend "s3" {
    encrypt        = true
    bucket         = "cisa-cool-terraform-state"
    dynamodb_table = "terraform-state-lock"
    role_arn       = "arn:aws:iam::608004238745:role/TerraformStateAccess"
    region         = "us-east-1"
    key            = "cool-shared-services-freeipa/terraform.tfstate"
  }
}

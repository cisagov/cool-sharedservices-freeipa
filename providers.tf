provider "aws" {
  region = var.aws_region
  assume_role {
    role_arn     = var.default_role_arn
    session_name = "terraform-default"
  }
}

provider "aws" {
  alias  = "public_dns"
  region = var.aws_region
  assume_role {
    role_arn     = var.dns_role_arn
    session_name = "terraform-public-dns"
  }
}

provider "aws" {
  alias  = "cert_create_read_role"
  region = var.aws_region
  assume_role {
    role_arn     = var.cert_create_read_role_arn
    session_name = "terraform-cert"
  }
}

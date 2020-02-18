provider "aws" {
  profile = "cool-sharedservices-provisionaccount"
  region  = var.aws_region
}

provider "aws" {
  alias   = "public_dns"
  profile = "cool-olddns-route53fullaccess"
  region  = var.aws_region
}

provider "aws" {
  alias   = "cert_create_read_role"
  profile = "cool-dns-provisioncertificatereadroles"
  region  = var.aws_region
}

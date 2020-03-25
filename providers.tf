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
  alias   = "provision_certificate_read_role"
  profile = "cool-dns-provisioncertificatereadroles"
  region  = var.aws_region
}

provider "aws" {
  alias   = "organizationsreadonly"
  profile = "cool-master-organizationsreadonly"
  region  = var.aws_region
}

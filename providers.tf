provider "aws" {
  profile = "cool-sharedservices-provisionaccount"
  region  = var.aws_region
}

# This provider isn't used, since we choose not associate public IPs
# with the FreeIPA master and replicas.  We do, however, have to
# provide a valid provider to the Terraform module.
provider "aws" {
  alias   = "public_dns"
  profile = "cool-dns-route53resourcechange-cyber.dhs.gov"
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

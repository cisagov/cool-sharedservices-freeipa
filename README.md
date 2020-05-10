# cool-sharedservices-freeipa #

[![GitHub Build Status](https://github.com/cisagov/cool-sharedservices-freeipa/workflows/build/badge.svg)](https://github.com/cisagov/cool-sharedservices-freeipa/actions)

This is a Terraform module for creating a FreeIPA master and multiple
FreeIPA replicas in the COOL shared services environment.  This
deployment should be laid down on top of
[cisagov/cool-sharedservices-networking](https://github.com/cisagov/cool-sharedservices-networking).

## Usage ##

```hcl
module "example" {
  source = "github.com/cisagov/cool-sharedservices-freeipa"

  admin_pw                         = "thepassword"
  aws_region                       = "us-east-1"
  cert_bucket_name                 = "certbucket"
  cert_create_read_role_arn        = "arn:aws:iam::123456789012:role/CertCreateReadRole"
  cool_domain                      = "example.com"
  default_role_arn                 = "arn:aws:iam::123456789012:role/TerraformRole"
  directory_service_pw             = "thepassword"
  dns_role_arn                     = "arn:aws:iam::123456789012:role/DnsRole"
  hostname                         = "ipa.example.com"
  master_cert_pw                   = "lemmy"
  public_zone_name                 = "ipa.example.gov"
  replica1_cert_pw                 = "lemmy"
  replica2_cert_pw                 = "lemmy"
  tags                             = {
    Key1 = "Value1"
    Key2 = "Value2"
  }
  trusted_cidr_blocks              = [
    "10.99.49.0/24",
    "10.99.52.0/24"
  ]
}
```

## Inputs ##

| Name | Description | Type | Default | Required |
|------|-------------|:----:|:-------:|:--------:|
| admin_pw | The password for the Kerberos admin role. | string | | yes |
| aws_region | The AWS region to deploy into (e.g. us-east-1). | string | | yes |
| cert_bucket_name | The name of the AWS S3 bucket where certificates are stored. | string | `cool-certificates` | no |
| cool_domain | The domain where the COOL resources reside (e.g. "cool.cyber.dhs.gov"). | string | `cool.cyber.dhs.gov` | no |
| directory_service_pw | The password for the IPA master's directory service. | string | | yes |
| master_cert_pw | The password for the IPA master's certificate. | string | | yes |
| provisionaccount_role_name | The name of the IAM role that allows sufficient permissions to provision all AWS resources in the Shared Services account. | string | `ProvisionAccount` | no |
| provisionfreeipa_policy_description | The description to associate with the IAM policy that allows provisioning of FreeIPA in the Shared Services account. | string | `Allows provisioning of FreeIPA in the Shared Services account.` | no |
| provisionfreeipa_policy_name | The name to associate with the IAM policy that allows provisioning of FreeIPA in the Shared Services account. | string | `ProvisionFreeIPA` | no |
| public_zone_name | The name of the public Route53 zone where public DNS records should be created (e.g. "cyber.dhs.gov."). | string | `cyber.dhs.gov` | no |
| replica1_cert_pw | The password for the first IPA replica's certificate. | string | | yes |
| replica2_cert_pw | The password for the second IPA replica's certificate. | string | | yes |
| tags | Tags to apply to all AWS resources created. | map(string) | `{}` | no |
| trusted_cidr_blocks | A list of the CIDR blocks outside the VPC that are allowed to access the IPA servers (e.g. ["10.10.0.0/16", "10.11.0.0/16"]). | list(string) | `[]` | no |

## Outputs ##

| Name | Description |
|------|-------------|
| client_security_group | The IPA client security group. |
| master_certificate_read_role | The IAM role used by the IPA master to read its certificate information. |
| master | The IPA master EC2 instance. |
| replica1_certificate_read_role | The IAM role used by the first IPA replica to read its certificate information. |
| replica1 | The first IPA replica EC2 instance. |
| replica2_certificate_read_role | The IAM role used by the second IPA replica to read its certificate information. |
| replica2 | The second IPA replica EC2 instance. |
| server_security_group | The IPA server security group. |

## Notes ##

Running `pre-commit` requires running `terraform init` in every directory that
contains Terraform code. In this repository, that is only the main directory.

## Contributing ##

We welcome contributions!  Please see [here](CONTRIBUTING.md) for
details.

## License ##

This project is in the worldwide [public domain](LICENSE).

This project is in the public domain within the United States, and
copyright and related rights in the work worldwide are waived through
the [CC0 1.0 Universal public domain
dedication](https://creativecommons.org/publicdomain/zero/1.0/).

All contributions to this project will be released under the CC0
dedication. By submitting a pull request, you are agreeing to comply
with this waiver of copyright interest.

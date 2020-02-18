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
  master_private_reverse_zone_id   = "ZLY47KYR9X93M"
  master_subnet_id                 = "subnet-0123456789abcdef0"
  private_zone_id                  = "ZKX36JXQ8W82L"
  public_zone_name                 = "ipa.example.gov"
  replica1_cert_pw                 = "lemmy"
  replica1_private_reverse_zone_id = "ZLY47KYR9X93N"
  replica1_subnet_id               = "subnet-0123456789abcdef1"
  replica2_cert_pw                 = "lemmy"
  replica2_private_reverse_zone_id = "ZLY47KYR9X93N"
  replica2_subnet_id               = "subnet-0123456789abcdef1"
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
| master_private_reverse_zone_id | The zone ID corresponding to the private Route53 reverse zone appropriate for the IPA master (e.g. "Z01234567YYYYY89FFF0T"). | string | | yes |
| master_subnet_id | The ID of the subnet where the IPA master is to be deployed (e.g. "subnet-0123456789abcdef0"). | string | | yes |
| private_zone_id | The zone ID corresponding to the private Route53 zone for the COOL shared services VPC (e.g. "Z01234567YYYYY89FFF0T"). | string | | yes |
| public_zone_name | The name of the public Route53 zone where public DNS records should be created (e.g. "cyber.dhs.gov."). | string | `cyber.dhs.gov` | no |
| replica1_cert_pw | The password for the first IPA replica's certificate. | string | | yes |
| replica1_private_reverse_zone_id | The zone ID corresponding to the private Route53 reverse zone appropriate for the first IPA replica (e.g. "Z01234567YYYYY89FFF0T"). | string | | yes |
| replica1_subnet_id | The ID of the subnet where the first IPA replica is to be deployed (e.g. "subnet-0123456789abcdef0"). | string | | yes |
| replica2_cert_pw | The password for the second IPA replica's certificate. | string | | yes |
| replica2_private_reverse_zone_id | The zone ID corresponding to the private Route53 reverse zone appropriate for the second IPA replica (e.g. "Z01234567YYYYY89FFF0T"). | string | | yes |
| replica2_subnet_id | The ID of the subnet where the second IPA replica is to be deployed (e.g. "subnet-0123456789abcdef0"). | string | | yes |
| tags | Tags to apply to all AWS resources created. | map(string) | `{}` | no |
| trusted_cidr_blocks | A list of the CIDR blocks outside the VPC that are allowed to access the IPA servers (e.g. ["10.10.0.0/16", "10.11.0.0/16"]). | list(string) | `[]` | no |

## Outputs ##

| Name | Description |
|------|-------------|
| client_security_group_id | The ID corresponding to the IPA client security group. |
| master_cert_read_role_arn | The ARN corresponding to the role used by the IPA master to read its certificate information. |
| master_id | The EC2 instance ID corresponding to the IPA master. |
| replica1_cert_read_role_arn | The ARN corresponding to the role used by the first IPA replica to read its certificate information. |
| replica1_id | The EC2 instance ID corresponding to the first IPA replica. |
| replica2_cert_read_role_arn | The ARN corresponding to the role used by the second IPA replica to read its certificate information. |
| replica2_id | The EC2 instance ID corresponding to the second IPA replica. |
| server_security_group_id | The ID corresponding to the IPA server security group. |

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

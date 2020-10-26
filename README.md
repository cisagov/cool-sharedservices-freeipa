# cool-sharedservices-freeipa #

[![GitHub Build Status](https://github.com/cisagov/cool-sharedservices-freeipa/workflows/build/badge.svg)](https://github.com/cisagov/cool-sharedservices-freeipa/actions)

This is a Terraform module for creating a FreeIPA server cluster in
the COOL shared services environment.  This deployment should be laid
down on top of
[cisagov/cool-sharedservices-networking](https://github.com/cisagov/cool-sharedservices-networking).

## Pre-requisites ##

- [Terraform](https://www.terraform.io/) installed on your system.
- An accessible AWS S3 bucket to store Terraform state
  (specified in [backend.tf](backend.tf)).
- An accessible AWS DynamoDB database to store the Terraform state lock
  (specified in [backend.tf](backend.tf)).
- Access to all of the Terraform remote states specified in
  [remote_states.tf](remote_states.tf).

## Usage ##

```hcl
module "example" {
  source = "github.com/cisagov/cool-sharedservices-freeipa"

  aws_region                       = "us-east-1"
  cool_domain                      = "example.com"
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

## Requirements ##

| Name | Version |
|------|---------|
| terraform | ~> 0.12.0 |
| aws | ~> 3.0 |

## Providers ##

| Name | Version |
|------|---------|
| aws | ~> 3.0 |
| aws.organizationsreadonly | ~> 3.0 |
| aws.sharedservicesprovisionaccount | ~> 3.0 |
| terraform | n/a |

## Inputs ##

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| advertise_ipa_servers | A map whose keys are the leading part of the IPA servers' hostnames and whose keys are boolean values denoting whether that particular server should be advertised as an IPA server (e.g. {"ipa0" = true, "ipa1" = false}).  If the boolean value is false then the A and PTR records for the server are still created, but it is not listed in SVC records, etc. | `map(bool)` | `{"ipa0": true, "ipa1": true, "ipa2": true}` | no |
| aws_region | The AWS region where the shared services account is to be created (e.g. "us-east-1"). | `string` | `us-east-1` | no |
| cool_domain | The domain where the COOL resources reside (e.g. "cool.cyber.dhs.gov"). | `string` | `cool.cyber.dhs.gov` | no |
| provisionaccount_role_name | The name of the IAM role that allows sufficient permissions to provision all AWS resources in the Shared Services account. | `string` | `ProvisionAccount` | no |
| provisionfreeipa_policy_description | The description to associate with the IAM policy that allows provisioning of FreeIPA in the Shared Services account. | `string` | `Allows provisioning of FreeIPA in the Shared Services account.` | no |
| provisionfreeipa_policy_name | The name to assign the IAM policy that allows provisioning of FreeIPA in the Shared Services account. | `string` | `ProvisionFreeIPA` | no |
| tags | Tags to apply to all AWS resources created. | `map(string)` | `{}` | no |
| trusted_cidr_blocks | A list of the CIDR blocks outside the VPC that are allowed to access the IPA servers (e.g. ["10.10.0.0/16", "10.11.0.0/16"]). | `list(string)` | `[]` | no |
| ttl | The TTL value to use for Route53 DNS records (e.g. 86400).  A smaller value may be useful when the DNS records are changing often, for example when testing. | `number` | `86400` | no |

## Outputs ##

| Name | Description |
|------|-------------|
| client_security_group | The IPA client security group. |
| server0 | The first IPA server EC2 instance. |
| server1 | The second IPA server EC2 instance. |
| server2 | The third IPA server EC2 instance. |
| server_security_group | The IPA server security group. |

## Notes ##

Running `pre-commit` requires running `terraform init` in every directory that
contains Terraform code. In this repository, that is only the main directory.

## Contributing ##

We welcome contributions!  Please see [`CONTRIBUTING.md`](CONTRIBUTING.md) for
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

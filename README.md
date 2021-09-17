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

  aws_region          = "us-east-1"
  cool_domain         = "example.com"
  trusted_cidr_blocks = [
    "10.99.49.0/24",
    "10.99.52.0/24"
  ]
}
```

## Requirements ##

| Name | Version |
|------|---------|
| terraform | ~> 0.14.0 |
| aws | ~> 3.38 |

## Providers ##

| Name | Version |
|------|---------|
| aws | ~> 3.38 |
| aws.organizationsreadonly | ~> 3.38 |
| aws.sharedservicesprovisionaccount | ~> 3.38 |
| terraform | n/a |

## Modules ##

| Name | Source | Version |
|------|--------|---------|
| dns | ./dns | n/a |
| ipa0 | github.com/cisagov/freeipa-server-tf-module | n/a |
| ipa1 | github.com/cisagov/freeipa-server-tf-module | n/a |
| ipa2 | github.com/cisagov/freeipa-server-tf-module | n/a |
| security\_groups | ./security_groups | n/a |

## Resources ##

| Name | Type |
|------|------|
| [aws_iam_policy.provisionfreeipa_policy](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_policy) | resource |
| [aws_iam_role_policy_attachment.provisionfreeipa_policy_attachment](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role_policy_attachment) | resource |
| [aws_caller_identity.current](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/caller_identity) | data source |
| [aws_caller_identity.sharedservices](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/caller_identity) | data source |
| [aws_iam_policy_document.provisionfreeipa_policy_doc](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy_document) | data source |
| [aws_organizations_organization.cool](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/organizations_organization) | data source |
| [terraform_remote_state.cdm](https://registry.terraform.io/providers/hashicorp/terraform/latest/docs/data-sources/remote_state) | data source |
| [terraform_remote_state.images_parameterstore](https://registry.terraform.io/providers/hashicorp/terraform/latest/docs/data-sources/remote_state) | data source |
| [terraform_remote_state.master](https://registry.terraform.io/providers/hashicorp/terraform/latest/docs/data-sources/remote_state) | data source |
| [terraform_remote_state.networking](https://registry.terraform.io/providers/hashicorp/terraform/latest/docs/data-sources/remote_state) | data source |
| [terraform_remote_state.sharedservices](https://registry.terraform.io/providers/hashicorp/terraform/latest/docs/data-sources/remote_state) | data source |

## Inputs ##

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| advertise\_ipa\_servers | A map whose keys are the leading part of the IPA servers' hostnames and whose keys are boolean values denoting whether that particular server should be advertised as an IPA server (e.g. {"ipa0" = true, "ipa1" = false}).  If the boolean value is false then the A and PTR records for the server are still created, but it is not listed in SVC records, etc. | `map(bool)` | `{"ipa0": true, "ipa1": true, "ipa2": true}` | no |
| aws\_region | The AWS region where the shared services account is to be created (e.g. "us-east-1"). | `string` | `"us-east-1"` | no |
| cool\_domain | The domain where the COOL resources reside (e.g. "cool.cyber.dhs.gov"). | `string` | `"cool.cyber.dhs.gov"` | no |
| nessus\_hostname\_key | The SSM Parameter Store key whose corresponding value contains the hostname of the CDM Tenable Nessus server to which the Nessus Agent should link (e.g. /cdm/nessus/hostname). | `string` | `"/cdm/nessus_hostname"` | no |
| nessus\_key\_key | The SSM Parameter Store key whose corresponding value contains the secret key that the Nessus Agent should use when linking with the CDM Tenable Nessus server (e.g. /cdm/nessus/key). | `string` | `"/cdm/nessus_key"` | no |
| nessus\_port\_key | The SSM Parameter Store key whose corresponding value contains the port to which the Nessus Agent should connect when linking with the CDM Tenable Nessus server (e.g. /cdm/nessus/port). | `string` | `"/cdm/nessus_port"` | no |
| provisionaccount\_role\_name | The name of the IAM role that allows sufficient permissions to provision all AWS resources in the Shared Services account. | `string` | `"ProvisionAccount"` | no |
| provisionfreeipa\_policy\_description | The description to associate with the IAM policy that allows provisioning of FreeIPA in the Shared Services account. | `string` | `"Allows provisioning of FreeIPA in the Shared Services account."` | no |
| provisionfreeipa\_policy\_name | The name to assign the IAM policy that allows provisioning of FreeIPA in the Shared Services account. | `string` | `"ProvisionFreeIPA"` | no |
| tags | Tags to apply to all AWS resources created. | `map(string)` | `{}` | no |
| trusted\_cidr\_blocks | A list of the CIDR blocks outside the VPC that are allowed to access the IPA servers (e.g. ["10.10.0.0/16", "10.11.0.0/16"]). | `list(string)` | `[]` | no |
| ttl | The TTL value to use for Route53 DNS records (e.g. 60). | `number` | `60` | no |

## Outputs ##

| Name | Description |
|------|-------------|
| client\_security\_group | The IPA client security group. |
| server0 | The first IPA server EC2 instance. |
| server1 | The second IPA server EC2 instance. |
| server2 | The third IPA server EC2 instance. |
| server\_security\_group | The IPA server security group. |

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

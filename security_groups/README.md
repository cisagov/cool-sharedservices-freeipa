# cool-sharedservices-freeipa Security Group submodule #

This is a Terraform module for creating the IPA server and client
security groups in the COOL shared services environment.

## Usage ##

```hcl
module "example" {
  source = "./security_groups"

  tags                = {
    Key1 = "Value1"
    Key2 = "Value2"
  }
  trusted_cidr_blocks = ["10.10.0.0/16"]
  vpc_id              = "vpc-2f09a348"
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

## Inputs ##

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| tags | Tags to apply to all AWS resources created. | `map(string)` | `{}` | no |
| trusted_cidr_blocks | A list of the CIDR blocks outside the VPC that are allowed to access the IPA servers (e.g. ["10.10.0.0/16", "10.11.0.0/16"]). | `list(string)` | `[]` | no |
| vpc_id | The ID of the VPC where the IPA cluster is to be instantiated (e.g. vpc-2f09a348). | `string` | n/a | yes |

## Outputs ##

| Name | Description |
|------|-------------|
| client | The IPA client security group. |
| server | The IPA server security group. |

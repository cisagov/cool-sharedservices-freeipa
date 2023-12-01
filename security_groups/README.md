# cool-sharedservices-freeipa Security Group submodule #

This is a Terraform module for creating the IPA server and client
security groups in the COOL shared services environment.

## Usage ##

```hcl
module "example" {
  source = "./security_groups"

  trusted_cidr_blocks = ["10.10.0.0/16"]
  vpc_id              = "vpc-2f09a348"
}
```

<!-- BEGIN_TF_DOCS -->
## Requirements ##

| Name | Version |
|------|---------|
| terraform | ~> 1.0 |
| aws | ~> 4.9 |

## Providers ##

| Name | Version |
|------|---------|
| aws | ~> 4.9 |

## Modules ##

No modules.

## Resources ##

| Name | Type |
|------|------|
| [aws_security_group.client](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/security_group) | resource |
| [aws_security_group.server](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/security_group) | resource |
| [aws_security_group_rule.client_egress](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/security_group_rule) | resource |
| [aws_security_group_rule.server_egress_self](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/security_group_rule) | resource |
| [aws_security_group_rule.server_http_egress](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/security_group_rule) | resource |
| [aws_security_group_rule.server_https_egress](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/security_group_rule) | resource |
| [aws_security_group_rule.server_ingress_clients](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/security_group_rule) | resource |
| [aws_security_group_rule.server_ingress_self](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/security_group_rule) | resource |
| [aws_security_group_rule.server_ingress_trusted](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/security_group_rule) | resource |

## Inputs ##

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| trusted\_cidr\_blocks | A list of the CIDR blocks outside the VPC that are allowed to access the IPA servers (e.g. ["10.10.0.0/16", "10.11.0.0/16"]). | `list(string)` | `[]` | no |
| vpc\_id | The ID of the VPC where the IPA cluster is to be instantiated (e.g. vpc-2f09a348). | `string` | n/a | yes |

## Outputs ##

| Name | Description |
|------|-------------|
| client | The IPA client security group. |
| server | The IPA server security group. |
<!-- END_TF_DOCS -->

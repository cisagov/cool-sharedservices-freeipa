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

## Requirements ##

| Name | Version |
|------|---------|
| terraform | ~> 1.0 |
| aws | ~> 3.38 |

## Providers ##

| Name | Version |
|------|---------|
| aws | ~> 3.38 |

## Modules ##

No modules.

## Resources ##

| Name | Type |
|------|------|
| [aws_security_group.client](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/security_group) | resource |
| [aws_security_group.server](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/security_group) | resource |
| [aws_security_group_rule.client_egress_to_load_balancer](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/security_group_rule) | resource |
| [aws_security_group_rule.client_egress_to_servers](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/security_group_rule) | resource |
| [aws_security_group_rule.server_egress_self](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/security_group_rule) | resource |
| [aws_security_group_rule.server_http_egress](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/security_group_rule) | resource |
| [aws_security_group_rule.server_https_egress](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/security_group_rule) | resource |
| [aws_security_group_rule.server_ingress_clients](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/security_group_rule) | resource |
| [aws_security_group_rule.server_ingress_load_balancer](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/security_group_rule) | resource |
| [aws_security_group_rule.server_ingress_self](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/security_group_rule) | resource |
| [aws_security_group_rule.server_ingress_trusted](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/security_group_rule) | resource |

## Inputs ##

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| load\_balancer\_ips | A list of IPv4 addresses that are the IPs corresponding to a load balancer in front of the IPA cluster (e.g. ["192.168.1.4", "192.168.1.4"]).  These IPs must reside within the VPC where the IPA cluster is to be instantiated. | `list(string)` | `[]` | no |
| trusted\_cidr\_blocks | A list of the CIDR blocks outside the VPC that are allowed to access the IPA servers (e.g. ["10.10.0.0/16", "10.11.0.0/16"]). | `list(string)` | `[]` | no |
| vpc\_id | The ID of the VPC where the IPA cluster is to be instantiated (e.g. vpc-2f09a348). | `string` | n/a | yes |

## Outputs ##

| Name | Description |
|------|-------------|
| client | The IPA client security group. |
| server | The IPA server security group. |

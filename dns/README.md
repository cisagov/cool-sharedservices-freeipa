# cool-sharedservices-freeipa DNS submodule #

This is a Terraform module for creating the DNS records for a FreeIPA
cluster in the COOL shared services environment.

## Usage ##

```hcl
resource "aws_lb" "example" {
  internal                         = true
  load_balancer_type               = "network"
  subnets                          = local.subnet_ids
}

module "example" {
  source = "./dns"

  domain                 = "example.com"
  hostname               = "ipa"
  load_balancer_dns_name = aws_lb.example.dns_name
  load_balancer_zone_id  = aws_lb.example.zone_id
  ttl                    = 60
  zone_id                = "ZKX36JXQ8W93M"
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
| [aws_route53_record.ca_A](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/route53_record) | resource |
| [aws_route53_record.cluster_A](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/route53_record) | resource |
| [aws_route53_record.kerberos_TXT](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/route53_record) | resource |
| [aws_route53_record.ldap_SRV](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/route53_record) | resource |
| [aws_route53_record.ldaps_SRV](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/route53_record) | resource |
| [aws_route53_record.master_SRV](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/route53_record) | resource |
| [aws_route53_record.password_SRV](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/route53_record) | resource |
| [aws_route53_record.server_SRV](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/route53_record) | resource |

## Inputs ##

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| domain | The domain for the IPA cluster (e.g. example.com). | `string` | n/a | yes |
| hostname | The hostname portion of the IPA FQDN (e.g. ipa).  This value and the value of the domain variable comprise the FQDN of the IPA cluster. | `string` | n/a | yes |
| load\_balancer\_dns\_name | The Route53 DNS name of the Network Load Balancer in front of the IPA cluster (e.g. IPA-0123456789abcdef.elb.us-east-1.amazonaws.com). | `string` | n/a | yes |
| load\_balancer\_zone\_id | The Route53 DNS zone ID of the Network Load Balancer in front of the IPA cluster (e.g. ZKX36JXQ8W93M). | `string` | n/a | yes |
| ttl | The TTL value to use for Route53 DNS records (e.g. 86400).  A smaller value may be useful when the DNS records are changing often, for example when testing. | `number` | `60` | no |
| zone\_id | The zone ID corresponding to the private Route53 zone where the Kerberos-related DNS records should be created (e.g. ZKX36JXQ8W93M). | `string` | n/a | yes |

## Outputs ##

No outputs.

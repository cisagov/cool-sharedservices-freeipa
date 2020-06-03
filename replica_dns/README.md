# cool-sharedservices-freeipa replica_dns submodule #

This is a Terraform module for creating the DNS records for a FreeIPA
replica in the COOL shared services environment.

## Usage ##

```hcl
module "example" {
  source = "./replica_dns"

  domain          = "example.com"
  hostname        = "ipa.example.com"
  ip              = "10.1.1.11"
  reverse_zone_id = "ZKX36JXQ8W82L"
  ttl             = 60
  zone_id         = "ZKX36JXQ8W93M"
}
```

## Requirements ##

| Name | Version |
|------|---------|
| terraform | >= 0.12 |

## Providers ##

| Name | Version |
|------|---------|
| aws | n/a |

## Inputs ##

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| domain | The domain for the IPA master (e.g. example.com). | `string` | n/a | yes |
| hostname | The hostname of the IPA master (e.g. ipa.example.com). | `string` | n/a | yes |
| ip | The IP of the IPA master (e.g. 10.11.1.5). | `string` | n/a | yes |
| reverse_zone_id | The zone ID corresponding to the private Route53 reverse zone where the PTR records related to the IPA master should be created (e.g. ZKX36JXQ8W82L). | `string` | n/a | yes |
| ttl | The TTL value to use for Route53 DNS records (e.g. 86400).  A smaller value may be useful when the DNS records are changing often, for example when testing. | `number` | `86400` | no |
| zone_id | The zone ID corresponding to the private Route53 zone where the Kerberos-related DNS records should be created (e.g. ZKX36JXQ8W82L). | `string` | n/a | yes |

## Outputs ##

No output.

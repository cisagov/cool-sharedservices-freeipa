# cool-sharedservices-freeipa DNS submodule #

This is a Terraform module for creating the DNS records for a FreeIPA
cluster in the COOL shared services environment.

Note that the DNS records are created such that requests are load
balanced across all FreeIPA servers listed in the `hostname_ip_map`
input variable.

## Usage ##

```hcl
module "example" {
  source = "./master_dns"

  domain          = "example.com"
  hostname_ip_map = "ipa.example.com"
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
| hostname_ip_map | A map whose keys are the hostnames of the IPA servers and whose values are the IPs corresponding to  those servers (e.g. {"ipa0.example.com" = "10.0.0.1", "ipa1.example.com" = "10.0.0.2"}). | `map(string)` | n/a | yes |
| reverse_zone_id | The zone ID corresponding to the private Route53 reverse zone where the PTR records related to the IPA master should be created (e.g. ZKX36JXQ8W82L). | `string` | n/a | yes |
| ttl | The TTL value to use for Route53 DNS records (e.g. 86400).  A smaller value may be useful when the DNS records are changing often, for example when testing. | `number` | `86400` | no |
| zone_id | The zone ID corresponding to the private Route53 zone where the Kerberos-related DNS records should be created (e.g. ZKX36JXQ8W82L). | `string` | n/a | yes |

## Outputs ##

No output.

# cool-sharedservices-freeipa DNS submodule #

This is a Terraform module for creating the DNS records for a FreeIPA
cluster in the COOL shared services environment.

Note that the DNS records are created such that requests are load
balanced across all FreeIPA servers listed in the `hosts` input
variable.

## Usage ##

```hcl
module "example" {
  source = "./master_dns"

  domain          = "example.com"
  hosts           = {
    "ipa0.example.com" = {
      ip              = "10.0.0.1"
      reverse_zone_id = "ZKX36JXQ8W82L"
      advertise       = true
    }
    "ipa1.example.com" = {
      ip              = "10.0.0.2"
      reverse_zone_id = "ZKX36JXQ8W93M"
      advertise       = false
    }
  }
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
| hosts | A map whose keys are the hostnames of the IPA servers and whose values are maps containing the IP and reverse zone ID corresponding to that hostname, as well as a boolean value indicating whether the host should be advertised as an IPA server (e.g. {"ipa0.example.com" = {"ip" = "10.0.0.1", "reverse_zone_id" = "ZKX36JXQ8W82L", "advertise" = true}, "ipa1.example.com" = {"ip" = "10.0.0.2", "reverse_zone_id" = "ZKX36JXQ8W93M", "advertise" = false}).  If the boolean value is false then the A and PTR records for the server are still created, but it is not listed in SVC records, etc. | `map(object({ ip = string, reverse_zone_id = string, advertise = bool }))` | n/a | yes |
| ttl | The TTL value to use for Route53 DNS records (e.g. 86400).  A smaller value may be useful when the DNS records are changing often, for example when testing. | `number` | `86400` | no |
| zone_id | The zone ID corresponding to the private Route53 zone where the Kerberos-related DNS records should be created (e.g. ZKX36JXQ8W93M). | `string` | n/a | yes |

## Outputs ##

No output.
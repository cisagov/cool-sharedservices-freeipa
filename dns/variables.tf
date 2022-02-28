# ------------------------------------------------------------------------------
# Required parameters
#
# You must provide a value for each of these parameters.
# ------------------------------------------------------------------------------

variable "domain" {
  type        = string
  description = "The domain for the IPA cluster (e.g. example.com)."
}

variable "hostname" {
  type        = string
  description = "The hostname portion of the IPA FQDN (e.g. ipa).  This value and the value of the domain variable comprise the FQDN of the IPA cluster."
}

variable "load_balancer_dns_name" {
  type        = string
  description = "The Route53 DNS name of the Network Load Balancer in front of the IPA cluster (e.g. IPA-0123456789abcdef.elb.us-east-1.amazonaws.com)."
}

variable "load_balancer_zone_id" {
  type        = string
  description = "The Route53 DNS zone ID of the Network Load Balancer in front of the IPA cluster (e.g. ZKX36JXQ8W93M)."
}

variable "zone_id" {
  type        = string
  description = "The zone ID corresponding to the private Route53 zone where the Kerberos-related DNS records should be created (e.g. ZKX36JXQ8W93M)."
}

# ------------------------------------------------------------------------------
# Optional parameters
#
# These parameters have reasonable defaults.
# ------------------------------------------------------------------------------

variable "ttl" {
  type        = number
  description = "The TTL value to use for Route53 DNS records (e.g. 86400).  A smaller value may be useful when the DNS records are changing often, for example when testing."
  default     = 60
}

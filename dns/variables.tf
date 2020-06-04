# ------------------------------------------------------------------------------
# Required parameters
#
# You must provide a value for each of these parameters.
# ------------------------------------------------------------------------------

variable "domain" {
  type        = string
  description = "The domain for the IPA master (e.g. example.com)."
}

variable "hostname_ip_map" {
  type        = map(string)
  description = "A map whose keys are the hostnames of the IPA servers and whose values are the IPs corresponding to  those servers (e.g. {\"ipa0.example.com\" = \"10.0.0.1\", \"ipa1.example.com\" = \"10.0.0.2\"})."
}

variable "reverse_zone_id" {
  type        = string
  description = "The zone ID corresponding to the private Route53 reverse zone where the PTR records related to the IPA master should be created (e.g. ZKX36JXQ8W82L)."
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
  default     = 86400
}

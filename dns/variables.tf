# ------------------------------------------------------------------------------
# Required parameters
#
# You must provide a value for each of these parameters.
# ------------------------------------------------------------------------------

variable "domain" {
  type        = string
  description = "The domain for the IPA master (e.g. example.com)."
}

variable "hosts" {
  type        = map(object({ ip = string, reverse_zone_id = string, advertise = bool }))
  description = "A map whose keys are the hostnames of the IPA servers and whose values are maps containing the IP and reverse zone ID corresponding to that hostname, as well as a boolean value indicating whether the host should be advertised as an IPA server (e.g. {\"ipa0.example.com\" = {\"ip\" = \"10.0.0.1\", \"reverse_zone_id\" = \"ZKX36JXQ8W82L\", \"advertise\" = true}, \"ipa1.example.com\" = {\"ip\" = \"10.0.0.2\", \"reverse_zone_id\" = \"ZKX36JXQ8W93M\", \"advertise\" = false}).  If the boolean value is false then the A and PTR records for the server are still created, but it is not listed in SVC records, etc."
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

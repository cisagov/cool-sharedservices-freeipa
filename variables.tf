# ------------------------------------------------------------------------------
# Optional parameters
#
# These parameters have reasonable defaults.
# ------------------------------------------------------------------------------

variable "advertise_ipa_servers" {
  type        = map(bool)
  description = "A map whose keys are the leading part of the IPA servers' hostnames and whose keys are boolean values denoting whether that particular server should be advertised as an IPA server (e.g. {\"ipa0\" = true, \"ipa1\" = false}).  If the boolean value is false then the A and PTR records for the server are still created, but it is not listed in SVC records, etc."
  default = {
    "ipa0" = true
    "ipa1" = true
    "ipa2" = true
  }
}

variable "aws_region" {
  type        = string
  description = "The AWS region where the shared services account is to be created (e.g. \"us-east-1\")."
  default     = "us-east-1"
}

variable "cool_domain" {
  type        = string
  description = "The domain where the COOL resources reside (e.g. \"cool.cyber.dhs.gov\")."
  default     = "cool.cyber.dhs.gov"
}

variable "nessus_hostname_key" {
  type        = string
  description = "The SSM Parameter Store key whose corresponding value contains the hostname of the CDM Tenable Nessus server to which the Nessus Agent should link (e.g. /cdm/nessus/hostname)."
  default     = "/cdm/nessus_hostname"
}

variable "nessus_key_key" {
  type        = string
  description = "The SSM Parameter Store key whose corresponding value contains the secret key that the Nessus Agent should use when linking with the CDM Tenable Nessus server (e.g. /cdm/nessus/key)."
  default     = "/cdm/nessus_key"
}

variable "nessus_port_key" {
  type        = string
  description = "The SSM Parameter Store key whose corresponding value contains the port to which the Nessus Agent should connect when linking with the CDM Tenable Nessus server (e.g. /cdm/nessus/port)."
  default     = "/cdm/nessus_port"
}

variable "provisionaccount_role_name" {
  type        = string
  description = "The name of the IAM role that allows sufficient permissions to provision all AWS resources in the Shared Services account."
  default     = "ProvisionAccount"
}

variable "provisionfreeipa_policy_description" {
  type        = string
  description = "The description to associate with the IAM policy that allows provisioning of FreeIPA in the Shared Services account."
  default     = "Allows provisioning of FreeIPA in the Shared Services account."
}

variable "provisionfreeipa_policy_name" {
  type        = string
  description = "The name to assign the IAM policy that allows provisioning of FreeIPA in the Shared Services account."
  default     = "ProvisionFreeIPA"
}

variable "tags" {
  type        = map(string)
  description = "Tags to apply to all AWS resources created."
  default     = {}
}

variable "trusted_cidr_blocks" {
  type        = list(string)
  description = "A list of the CIDR blocks outside the VPC that are allowed to access the IPA servers (e.g. [\"10.10.0.0/16\", \"10.11.0.0/16\"])."
  default     = []
}

variable "ttl" {
  type        = number
  description = "The TTL value to use for Route53 DNS records (e.g. 3600).  A smaller value may be useful when the DNS records are changing often, for example when testing."
  default     = 3600
}

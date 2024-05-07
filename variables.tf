# ------------------------------------------------------------------------------
# Optional parameters
#
# These parameters have reasonable defaults.
# ------------------------------------------------------------------------------

variable "aws_region" {
  default     = "us-east-1"
  description = "The AWS region where the shared services account is to be created (e.g. \"us-east-1\")."
  type        = string
}

variable "cool_domain" {
  default     = "cool.cyber.dhs.gov"
  description = "The domain where the COOL resources reside (e.g. \"cool.cyber.dhs.gov\")."
  type        = string
}

variable "crowdstrike_falcon_sensor_customer_id_key" {
  default     = "/cdm/falcon/customer_id"
  description = "The SSM Parameter Store key whose corresponding value contains the customer ID for CrowdStrike Falcon (e.g. /cdm/falcon/customer_id)."
  type        = string
}

variable "crowdstrike_falcon_sensor_tags_key" {
  default     = "/cdm/falcon/tags"
  description = "The SSM Parameter Store key whose corresponding value contains a comma-delimited list of tags that are to be applied to CrowdStrike Falcon (e.g. /cdm/falcon/tags)."
  type        = string
}

variable "nessus_hostname_key" {
  default     = "/cdm/nessus_hostname"
  description = "The SSM Parameter Store key whose corresponding value contains the hostname of the CDM Tenable Nessus server to which the Nessus Agent should link (e.g. /cdm/nessus/hostname)."
  type        = string
}

variable "nessus_key_key" {
  default     = "/cdm/nessus_key"
  description = "The SSM Parameter Store key whose corresponding value contains the secret key that the Nessus Agent should use when linking with the CDM Tenable Nessus server (e.g. /cdm/nessus/key)."
  type        = string
}

variable "nessus_port_key" {
  default     = "/cdm/nessus_port"
  description = "The SSM Parameter Store key whose corresponding value contains the port to which the Nessus Agent should connect when linking with the CDM Tenable Nessus server (e.g. /cdm/nessus/port)."
  type        = string
}

variable "netbios_name" {
  default     = "COOL"
  description = "The NetBIOS name to be used by the server (e.g. EXAMPLE).  Note that NetBIOS names are restricted to at most 15 characters.  These characters must consist only of uppercase letters, numbers, and dashes."
  type        = string
  validation {
    condition     = length(var.netbios_name) <= 15 && length(regexall("[^A-Z0-9-]", var.netbios_name)) == 0
    error_message = "NetBIOS names are restricted to at most 15 characters.  These characters must consist only of uppercase letters, numbers, and dashes."
  }
}

variable "provisionaccount_role_name" {
  default     = "ProvisionAccount"
  description = "The name of the IAM role that allows sufficient permissions to provision all AWS resources in the Shared Services account."
  type        = string
}

variable "provisionfreeipa_policy_description" {
  default     = "Allows provisioning of FreeIPA in the Shared Services account."
  description = "The description to associate with the IAM policy that allows provisioning of FreeIPA in the Shared Services account."
  type        = string
}

variable "provisionfreeipa_policy_name" {
  default     = "ProvisionFreeIPA"
  description = "The name to assign the IAM policy that allows provisioning of FreeIPA in the Shared Services account."
  type        = string
}

variable "root_disk_size" {
  default     = 8
  description = "The size of the IPA instance's root disk in GiB."
  type        = number
}

variable "tags" {
  default     = {}
  description = "Tags to apply to all AWS resources created."
  type        = map(string)
}

variable "trusted_cidr_blocks" {
  default     = []
  description = "A list of the CIDR blocks outside the VPC that are allowed to access the IPA servers (e.g. [\"10.10.0.0/16\", \"10.11.0.0/16\"])."
  type        = list(string)
}

variable "ttl" {
  default     = 60
  description = "The TTL value to use for Route53 DNS records (e.g. 60)."
  type        = number
}

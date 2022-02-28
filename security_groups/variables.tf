# ------------------------------------------------------------------------------
# Required parameters
#
# You must provide a value for each of these parameters.
# ------------------------------------------------------------------------------

variable "vpc_id" {
  type        = string
  description = "The ID of the VPC where the IPA cluster is to be instantiated (e.g. vpc-2f09a348)."
}

# ------------------------------------------------------------------------------
# Optional parameters
#
# These parameters have reasonable defaults.
# ------------------------------------------------------------------------------

variable "load_balancer_ips" {
  type        = list(string)
  description = "A list of IPv4 addresses that are the IPs corresponding to a load balancer in front of the IPA cluster (e.g. [\"192.168.1.4\", \"192.168.1.4\"]).  These IPs must reside within the VPC where the IPA cluster is to be instantiated."
  default     = []
}

variable "trusted_cidr_blocks" {
  type        = list(string)
  description = "A list of the CIDR blocks outside the VPC that are allowed to access the IPA servers (e.g. [\"10.10.0.0/16\", \"10.11.0.0/16\"])."
  default     = []
}

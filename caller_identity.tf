# ------------------------------------------------------------------------------
# We can get the account ID of the Shared Services account from the
# provider's caller identity.
# ------------------------------------------------------------------------------
data "aws_caller_identity" "sharedservices" {
}

# This resource is used to look up account names corresponding to
# account IDs and vice versa.
data "aws_organizations_organization" "cool" {
  provider = aws.organizationsreadonly
}

# ------------------------------------------------------------------------------
# Evaluate expressions for use throughout this configuration.
# ------------------------------------------------------------------------------
locals {
  # Extract the user name of the current caller for use
  # as assume role session names.
  caller_user_name = split("/", data.aws_caller_identity.current.arn)[1]

  # The Shared Services account ID
  sharedservices_account_id = data.aws_caller_identity.sharedservices.account_id

  # Look up Shared Services account name from AWS organizations
  # provider
  sharedservices_account_name = [
    for account in data.aws_organizations_organization.cool.non_master_accounts :
    account.name
    if account.id == local.sharedservices_account_id
  ][0]

  # Determine the Images account ID of the same type (production, staging, etc.)
  # as the Shared Services account.
  # Account name format:  "ACCOUNT_NAME (ACCOUNT_TYPE)"
  #         For example:  "Shared Services (Production)"
  # NOTE: Originally, Images and Shared Services account names followed the
  # "ACCOUNT_NAME (ACCOUNT_TYPE)" format above, but our thinking has changed and
  # in newer environments the accounts are simply called "Images" and "Shared
  # Services".  However, until all legacy environments have been migrated to
  # this new naming scheme, we must check the Shared Services account name via
  # the regex below to determine whether we are using the legacy naming scheme
  # or not.
  sharedservices_account_name_type = length(regexall("\\(([^()]*)\\)", local.sharedservices_account_name)) == 1 ? "legacy" : "current"

  images_account_name_regex = local.sharedservices_account_name_type == "legacy" ? format("^Images \\(%s\\)$", trim(split("(", local.sharedservices_account_name)[1], ")")) : "^Images$"

  images_account_id = [
    for account in data.aws_organizations_organization.cool.non_master_accounts :
    account.id
    if length(regexall(local.images_account_name_regex, account.name)) > 0
  ][0]
}

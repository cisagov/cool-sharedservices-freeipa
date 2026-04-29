# ------------------------------------------------------------------------------
# Evaluate expressions for use throughout this configuration.
# ------------------------------------------------------------------------------
locals {
  # Extract the user name of the current caller for use
  # as assume role session names.
  caller_user_name = split("/", data.aws_caller_identity.current.arn)[1]

  # Look up the account ID of the "Images" account from AWS Organizations.
  images_account_id = [
    for account in data.aws_organizations_organization.cool.non_master_accounts :
    account.id
    if length(regexall("^Images$", account.name)) > 0
  ][0]

  base_ipa_security_group_ids = [
    module.security_groups.server.id,
    data.terraform_remote_state.networking.outputs.cloudwatch_agent_endpoint_client_security_group.id,
    data.terraform_remote_state.networking.outputs.ssm_agent_endpoint_client_security_group.id,
    # Used to pull the CDM agent parameters from SSM
    data.terraform_remote_state.networking.outputs.ssm_endpoint_client_security_group.id
  ]

  # Conditionally include the CDM security group, which is only used in Production
  ipa_security_group_ids = terraform.workspace == "production" ? concat(local.base_ipa_security_group_ids, [data.terraform_remote_state.cdm.outputs.cdm_security_group.id]) : local.base_ipa_security_group_ids
}

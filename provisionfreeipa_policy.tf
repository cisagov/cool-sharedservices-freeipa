# ------------------------------------------------------------------------------
# Create the IAM policy that allows all of the permissions necessary
# to provision FreeIPA in the Shared Services account.
# ------------------------------------------------------------------------------

data "aws_iam_policy_document" "provisionfreeipa_policy_doc" {
  # This policy needs to be more restricted, obviously
  statement {
    actions = [
      "*",
    ]

    resources = [
      "*",
    ]
  }
}

resource "aws_iam_policy" "provisionfreeipa_policy" {
  description = var.provisionfreeipa_policy_description
  name        = var.provisionfreeipa_policy_name
  policy      = data.aws_iam_policy_document.provisionfreeipa_policy_doc.json
}

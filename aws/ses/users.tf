locals {
  senders = toset([
    "authentik",
    "matrix",
    "mattermost",
    "netbox",
    "nextcloud",
    "upsilon",
    "vaultwarden",
  ])
}

resource "aws_iam_user" "smtp_users" {
  for_each = local.senders
  name     = each.key
}

resource "aws_iam_access_key" "smtp_users" {
  for_each = aws_iam_user.smtp_users
  user     = each.value.name
}

data "aws_iam_policy_document" "ses_sender" {
  statement {
    actions   = ["ses:SendRawEmail"]
    resources = ["*"]
  }
}

resource "aws_iam_policy" "ses_sender" {
  name   = "ses_sender"
  policy = data.aws_iam_policy_document.ses_sender.json
}

resource "aws_iam_user_policy_attachment" "ses_sender" {
  for_each   = aws_iam_user.smtp_users
  user       = each.value.name
  policy_arn = aws_iam_policy.ses_sender.arn
}

resource "vault_generic_secret" "infra_aws_ses_senders" {
  for_each = local.senders

  path = "infra/aws/ses/senders/${each.key}"
  data_json = jsonencode({
    username = aws_iam_access_key.smtp_users[each.key].id
    password = aws_iam_access_key.smtp_users[each.key].ses_smtp_password_v4
  })
}

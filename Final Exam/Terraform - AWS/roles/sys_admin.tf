data "aws_iam_policy_document" "sys_admin" {
  statement {
    sid = "AllowFullAccessForIAMAccountsAndOrgs"
    actions = [
      "iam:*",
      "organizations:*",
      "account:*",
    ]
    resources = ["*"]
  }
}

resource "aws_iam_policy" "sys_admin" {
  name   = var.sys_admin-role-name
  path   = "/${var.org}/"
  policy = data.aws_iam_policy_document.sys_admin.json
}

resource "aws_iam_role_policy_attachment" "sys_admin" {
  policy_arn = aws_iam_policy.sys_admin.arn
  role = aws_iam_role.sys_admin.id
}

resource "aws_iam_role" "sys_admin" {
  name = var.sys_admin-role-name
  path                  = "/${var.org}/"
  max_session_duration  = local.max_session_duration
  description           = "System Administrator Role"
  assume_role_policy = data.aws_iam_policy_document.sys_admin-assume-role-policy.json
  force_detach_policies = true
}

data "aws_iam_policy_document" "sys_admin-assume-role-policy" {
  statement {
    actions = [
      "sts:AssumeRole",
    ]

    principals {
      type        = "AWS"
      identifiers = var.sys_admin-trusted-entities
    }

    condition {
      variable = "aws:MultiFactorAuthPresent"
      test     = "Bool"
      values   = ["true"]
    }

    condition {
      variable = "aws:MultiFactorAuthAge"
      test     = "NumericLessThanEquals"
      values   = [local.max_session_duration]
    }
  }
}

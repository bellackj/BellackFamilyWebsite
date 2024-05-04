###########
# KMS Key #
###########
resource "aws_kms_key" "this" {
  bypass_policy_lockout_safety_check = var.bypass_policy_lockout_safety_check
  deletion_window_in_days            = var.deletion_window_in_days
  description                        = join("", ["KMS Key for encrypting", var.aws_service_name])
  enable_key_rotation                = var.enable_key_rotation
  is_enabled                         = var.is_enabled
  key_usage                          = var.key_usage
  multi_region                       = var.multi_region

  tags = merge(var.default_tags, {
    Name = join("-", [var.aws_service_name, "kms-key"])
  })
}

resource "aws_kms_key_policy" "this" {
  key_id = aws_kms_key.this.id
  policy = data.aws_iam_policy_document.this.json
}

data "aws_iam_policy_document" "this" {
  policy_id = join("-", [var.aws_service_name, "key-policy"])
  statement {
    sid = "Enable IAM management of the key"
    actions = [
      "kms:*"
    ]
    effect = "Allow"
    principals {
      type = "AWS"
      identifiers = [
        join(":", ["arn:aws:iam:", var.account_id, "root"])
      ]
    }
    resources = [aws_kms_key.this.arn]
  }
  statement {
    sid = "Allow specified principals to use the key"
    actions = [
      "kms:Encrypt",
      "kms:Decrypt",
      "kms:ReEncrypt",
      "kms:GenerateDataKey*",
      "kms:DescribeKey"
    ]
    effect = "Allow"
    principals {
      type        = "AWS"
      identifiers = var.aws_principals
    }
    principals {
      type        = "Service"
      identifiers = var.service_principals
    }
    resources = [aws_kms_key.this.arn]
  }
  statement {
    sid = "Allow autoscaling to create and revoke grants"
    actions = [
      "kms:CreateGrant",
      "kms:ListGrants",
      "kms:RevokeGrant"
    ]
    effect    = "Allow"
    resources = [aws_kms_key.this.arn]
    principals {
      type        = "AWS"
      identifiers = var.aws_principals
    }
    condition {
      test     = "Bool"
      variable = "kms:GrantIsForAWSResource"
      values   = ["true"]
    }
  }
}

resource "aws_kms_alias" "this" {
  name          = join("/", ["alias", var.aws_service_name, "key-alias"])
  target_key_id = aws_kms_key.this.id

  depends_on = [aws_kms_key.this]
}
#############################################
# S3 bucket for BellackFamily website files #
#############################################
resource "aws_s3_bucket" "bf_web_server_files" {
  bucket = "bellackfamily-web-server-files"

  tags = merge(local.default_tags, {
    Name = "bellackfamily-web-server-files"
  })
}

resource "aws_s3_buckey_server_side_encryption_configuration" "bf_bucket_encryption" {
  bucket = aws_s3_bucket.bf_web_server_files.id

  rule {
    apply_server_side_encryption_by_default {
      kms_master_key_id = module.bellackfamily_kms_key["s3"].kms_key_id
      sse_algorithm     = "aws:kms"
    }
  }
}

resource "aws_s3_bucket_versioning" "bf_bucket_versioning" {
  bucket = aws_s3_bucket.bf_web_server_files.id
  versioning_configuration {
    status = "Enabled"
  }
}

resource "aws_s3_bucket_policy" "allow_access" {
  bucket = aws_s3_bucket.bf_web_server_files.id
  policy = data.aws_iam_policy_document.allow_s3_access_from_aws_principal.json

  depends_on = [data.aws_iam_policy_document.allow_s3_access_from_aws_principal]
}

data "aws_iam_policy_document" "allow_s3_access_from_aws_principal" {
  statement {
    principals {
      type        = "AWS"
      identifiers = ["ec2.amazonaws.com"]
    }
    actions = [
      "s3:PutObject"
    ]
    resources = [
      aws_s3_bucket.bf_web_server_files.arn,
      join("/", [aws_s3_bucket.bf_web_server_files.arn, "*"])
    ]
  }
}
#################################################
# S3 bucket to hold remote Terraform state file #
#################################################
resource "aws_s3_bucket" "tf_state" {
  bucket = join("-", [local.bucket_name, data.aws_caller_identity.current.account_id])

  lifecycle {
    prevent_destroy = true
  }
}

resource "aws_s3_bucket_versioning" "tf_state_versioning" {
  bucket = aws_s3_bucket.tf_state.id
  versioning_configuration {
    status = "Enabled"
  }
}

########################################
# KMS Key to encrypt the TF state file #
########################################
resource "aws_kms_key" "state_kms_key" {
  description             = "This key is used to encrypt objects in the tf state s3 bucket"
  deletion_window_in_days = 10
}

resource "aws_s3_bucket_server_side_encryption_configuration" "tf_state_bucket" {
  bucket = aws_s3_bucket.tf_state.id

  rule {
    apply_server_side_encryption_by_default {
      kms_master_key_id = aws_kms_key.state_kms_key.arn
      sse_algorithm     = "aws:kms"
    }
  }
}

##############################################################
# DynamoDB table to store lock state of terraform state file #
##############################################################
resource "aws_dynamodb_table" "terraform_locks" {
  name         = "terraform-locks-bellackFamily"
  billing_mode = "PAY_PER_REQUEST"
  hash_key     = "LockID"

  attribute {
    name = "LockID"
    type = "S"
  }
}
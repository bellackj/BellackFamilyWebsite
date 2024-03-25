output "dynamodb_table" {
  value = aws_dynamodb_table.terraform_locks.id
}

output "terraform_s3_state_bucket" {
  value = aws_s3_bucket.tf_state.id
}
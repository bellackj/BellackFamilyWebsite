variable "account_id" {
  description = "The AWS account ID where the KMS key is provisioned"
  type        = string
  default     = null
}

variable "aws_principals" {
  description = "AWS Principals that can use this KMS key. Use [\"*\"] to allow all principals"
  type        = list(string)
  default     = []
}

variable "aws_service_name" {
  description = "The full name of the AWS service the KMS key will be used to encrypt"
  type        = string
  default     = null
}

variable "bypass_policy_lockout_safety_check" {
  description = "A flag to indicate whether to bypass the key policy lockout safety check."
  type        = bool
  default     = null
}

variable "default_tags" {
  description = "The default tags for the platform"
  type        = map(string)
  default     = {}
}

variable "deletion_window_in_days" {
  description = "The waiting period, in days"
  type        = number
  default     = null
}

variable "enable_key_rotation" {
  description = "Specifies whether key rotation is enabled. Default to 'true'"
  type        = bool
  default     = true
}

variable "is_enabled" {
  description = "Specifies whether the key is enabled. Defaults to 'true'"
  type        = bool
  default     = null
}

variable "key_usage" {
  description = "Specifies the intended use of the key"
  type        = string
  default     = null
}

variable "multi_region" {
  description = "Indicates whether the KMS key is a multi-region or regional key"
  type        = bool
  default     = null
}

variable "service_principals" {
  description = "AWS Servie Principals that can use the KMS key"
  type        = list(string)
  default     = []
}


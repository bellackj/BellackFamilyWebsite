##################################
# KMS keys for BellackFamily.com #
##################################
module "bellackfamily_kms_key" {
  for_each = local.kms_key_services

  source = "./modules/kms"

  account_id                         = local.account_id
  aws_service_name                   = each.key
  bypass_policy_lockout_safety_check = false
  deletion_window_in_days            = 7
  default_tags                       = local.default_tags
  enable_key_rotation                = true
  is_enabled                         = true
  key_usage                          = "ENCRYPT_DECRYPT"
  multi_region                       = false
  aws_principals                     = each.value.aws_principals
  service_principals                 = each.value.service_principals
}
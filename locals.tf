# Use this file to set variable and parameters for each instanciation of these configurations
locals {
  account_id = data.aws_caller_identity.current.account_id
  app_name   = "BellackFamily"

  region = data.aws_region.current.name
  availability_zones = [
    join("", [local.region, "a"]),
    join("", [local.region, "b"])
  ]
  default_tags = {
    Region  = local.region
    website = "BellackFamily.com"
  }

  # KMS Variables
  kms_key_services = {
    ebs = {
      aws_principals     = [local.account_id, join(":", ["arn:aws:iam:", local.account_id, "role/aws-service-role/autoscaling.amazonaws.com/AWSServiceRoleForAutoScaling"])]
      service_principals = ["ec2.amazonaws.com"]
    }
    logs = {
      aws_principals     = [local.account_id]
      service_principals = ["logs.amazonaws.com"]
    }
    s3 = {
      aws_principals     = [local.account_id]
      service_principals = ["delivery.logs.amazonaws.com", "s3.amazonaws.com"]
    }
    secretsmanager = {
      aws_principals     = [local.account_id]
      service_principals = ["secretsmanager.amazonaws.com"]
    }
  }
  # VPC variables
  vpc_cidr_block = "10.0.0.0/16"
  vpc_name       = "BellackFamily_VPC"

  public_subnets = [
    cidrsubnet(local.vpc_cidr_block, 8, 1),
    cidrsubnet(local.vpc_cidr_block, 8, 2)
  ]
  private_subnets = [
    cidrsubnet(local.vpc_cidr_block, 8, 10),
    cidrsubnet(local.vpc_cidr_block, 8, 20)
  ]
}
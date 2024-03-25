terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "5.40.0"
    }
  }

  backend "s3" {
    bucket         = "bellackfamily-tfstate-001395329297"
    key            = "bellackfamily/terraform.tfstate"
    region         = "us-east-1"
    dynamodb_table = "terraform-locks-bellackFamily"
    encrypt        = true
  }
}
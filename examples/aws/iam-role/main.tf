terraform {
  required_version = ">= 1.3.2"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 5.83"
    }
  }
}

provider "aws" {
  region = "us-east-1"
}

module "datafy_role_global" {
  source = "../../../aws/iam-role"

  account_id        = "123e4567-e89b-12d3-a456-426614174000"
  permissions_level = "AutoScaler"
  permissions_scope = "Global"
}

module "datafy_role_regional" {
  source = "../../../aws/iam-role"

  account_id        = "123e4567-e89b-12d3-a456-426614174001"
  permissions_level = "AutoScaler"
  permissions_scope = "Regional"
  regions           = ["us-east-1", "us-west-2"]
}

output "datafy_role_global_arn" {
  value = module.datafy_role_global.role_arn
}

output "datafy_role_regional_arn" {
  value = module.datafy_role_regional.role_arn
}

# Resource ARNs in DatafyIOPolicy follow the partition of the AWS provider.

mock_provider "aws" {
  mock_resource "aws_iam_openid_connect_provider" {
    defaults = {
      arn = "arn:aws:iam::123456789012:oidc-provider/oidc.datafy.io"
    }
  }

  mock_resource "aws_iam_role" {
    defaults = {
      arn = "arn:aws:iam::123456789012:role/DatafyIORole"
    }
  }
}

variables {
  account_id = "123e4567-e89b-12d3-a456-426614174000"
}

run "commercial_partition_arns" {
  command = plan

  override_data {
    target = data.aws_partition.current
    values = {
      partition = "aws"
    }
  }

  assert {
    condition = alltrue([
      for r in flatten([for s in slice(jsondecode(aws_iam_role_policy.datafy.policy).Statement, 3, 5) : s.Resource]) :
      startswith(r, "arn:aws:")
    ])
    error_message = "Tagging and KMS resource ARNs must use the aws partition"
  }
}

run "china_partition_arns" {
  command = plan

  override_data {
    target = data.aws_partition.current
    values = {
      partition = "aws-cn"
    }
  }

  variables {
    permissions_scope = "Regional"
    regions           = ["cn-north-1"]
  }

  assert {
    condition = alltrue([
      for r in flatten([for s in slice(jsondecode(aws_iam_role_policy.datafy.policy).Statement, 3, 5) : s.Resource]) :
      startswith(r, "arn:aws-cn:")
    ])
    error_message = "Tagging and KMS resource ARNs must use the aws-cn partition"
  }
}

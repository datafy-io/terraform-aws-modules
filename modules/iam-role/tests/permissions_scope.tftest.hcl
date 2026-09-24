# permissions_scope drives local.regional_condition, which is attached to every
# statement in DatafyIOPolicy except the region-agnostic describe statement.

mock_provider "aws" {
  mock_resource "aws_iam_openid_connect_provider" {
    defaults = {
      arn = "arn:aws:iam::123456789012:oidc-provider/oidc.datafy.io"
    }
  }
}

run "global_scope_has_no_region_condition" {
  variables {
    permissions_scope = "Global"
  }

  assert {
    condition = alltrue([
      for s in slice(jsondecode(aws_iam_role_policy.datafy.policy).Statement, 1, 5) :
      length(s.Condition) == 0
    ])
    error_message = "Global scope should leave every statement condition empty"
  }

  assert {
    condition     = aws_iam_role.datafy.tags["datafy:role:scope"] == "Global"
    error_message = "Role should be tagged with the Global scope"
  }
}

run "regional_scope_pins_requested_region" {
  variables {
    permissions_scope = "Regional"
    regions           = ["us-east-1", "eu-west-1"]
  }

  assert {
    condition = alltrue([
      for s in slice(jsondecode(aws_iam_role_policy.datafy.policy).Statement, 1, 5) :
      s.Condition.StringEquals["aws:RequestedRegion"] == ["us-east-1", "eu-west-1"]
    ])
    error_message = "Regional scope should pin aws:RequestedRegion to the configured regions on every conditioned statement"
  }

  assert {
    condition     = aws_iam_role.datafy.tags["datafy:role:scope"] == "Regional"
    error_message = "Role should be tagged with the Regional scope"
  }
}

run "region_agnostic_statement_is_never_conditioned" {
  variables {
    permissions_scope = "Regional"
    regions           = ["us-east-1"]
  }

  assert {
    condition     = !can(jsondecode(aws_iam_role_policy.datafy.policy).Statement[0].Condition)
    error_message = "The account-wide describe statement must stay unconditioned so region discovery keeps working"
  }

  assert {
    condition = jsondecode(aws_iam_role_policy.datafy.policy).Statement[0].Action == [
      "ec2:DescribeRegions",
      "ec2:DescribeAvailabilityZones",
      "ec2:DescribeInstanceTypes",
    ]
    error_message = "The unconditioned statement should only cover region and instance-type discovery"
  }
}

run "single_region" {
  variables {
    permissions_scope = "Regional"
    regions           = ["ap-south-1"]
  }

  assert {
    condition     = jsondecode(aws_iam_role_policy.datafy.policy).Statement[1].Condition.StringEquals["aws:RequestedRegion"] == ["ap-south-1"]
    error_message = "A single region should still render as a list"
  }
}

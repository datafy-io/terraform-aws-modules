# permissions_level flips the effect of the mutating statements: a Sensor role is
# read-only, an AutoScaler role may attach, snapshot, tag and decrypt volumes.

mock_provider "aws" {
  mock_resource "aws_iam_openid_connect_provider" {
    defaults = {
      arn = "arn:aws:iam::123456789012:oidc-provider/oidc.datafy.io"
    }
  }
}

run "autoscaler_allows_mutations" {
  variables {
    permissions_level = "AutoScaler"
  }

  assert {
    condition = alltrue([
      for s in jsondecode(aws_iam_role_policy.datafy.policy).Statement : s.Effect == "Allow"
    ])
    error_message = "An AutoScaler role should allow every statement in DatafyIOPolicy"
  }

  assert {
    condition     = aws_iam_role.datafy.tags["datafy:role:level"] == "AutoScaler"
    error_message = "Role should be tagged with the AutoScaler level"
  }
}

run "sensor_denies_mutations" {
  variables {
    permissions_level = "Sensor"
  }

  assert {
    condition = alltrue([
      for s in slice(jsondecode(aws_iam_role_policy.datafy.policy).Statement, 0, 2) : s.Effect == "Allow"
    ])
    error_message = "A Sensor role must keep read-only describe access"
  }

  assert {
    condition = alltrue([
      for s in slice(jsondecode(aws_iam_role_policy.datafy.policy).Statement, 2, 5) : s.Effect == "Deny"
    ])
    error_message = "A Sensor role must deny volume mutation, tagging and KMS statements"
  }

  assert {
    condition     = aws_iam_role.datafy.tags["datafy:role:level"] == "Sensor"
    error_message = "Role should be tagged with the Sensor level"
  }
}

run "validation_policy_is_scoped_to_the_role" {
  assert {
    condition     = jsondecode(aws_iam_role_policy.datafy_validation.policy).Statement[0].Resource == aws_iam_role.datafy.arn
    error_message = "The validation policy must only grant introspection on the role it is attached to"
  }

  assert {
    condition     = jsondecode(aws_iam_role_policy.datafy_validation.policy).Statement[0].Effect == "Allow"
    error_message = "The validation policy statement should be an Allow"
  }
}

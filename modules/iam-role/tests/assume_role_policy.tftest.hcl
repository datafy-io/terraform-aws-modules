# The trust policy binds the role to a Datafy OIDC subject. account_id narrows
# that subject from the whole platform to a single account or organization.

mock_provider "aws" {
  mock_resource "aws_iam_openid_connect_provider" {
    defaults = {
      arn = "arn:aws:iam::123456789012:oidc-provider/oidc.datafy.io"
    }
  }
}

run "without_account_id" {
  variables {
    account_id = ""
  }

  assert {
    condition     = jsondecode(aws_iam_role.datafy.assume_role_policy).Statement[0].Condition.StringEquals["oidc.datafy.io:sub"] == "datafy.io"
    error_message = "An empty account_id should trust the platform-wide datafy.io subject"
  }

  assert {
    condition     = aws_iam_role.datafy.tags["datafy:account:id"] == ""
    error_message = "The account id tag should be empty when no account_id is given"
  }
}

run "with_account_id" {
  variables {
    account_id = "123e4567-e89b-12d3-a456-426614174000"
  }

  assert {
    condition     = jsondecode(aws_iam_role.datafy.assume_role_policy).Statement[0].Condition.StringEquals["oidc.datafy.io:sub"] == "datafy.io/123e4567-e89b-12d3-a456-426614174000"
    error_message = "account_id should narrow the trusted subject to that account"
  }

  assert {
    condition     = aws_iam_role.datafy.tags["datafy:account:id"] == "123e4567-e89b-12d3-a456-426614174000"
    error_message = "The account id should be recorded as a tag"
  }
}

run "account_id_is_trimmed" {
  variables {
    account_id = "  123e4567-e89b-12d3-a456-426614174000  "
  }

  assert {
    condition     = jsondecode(aws_iam_role.datafy.assume_role_policy).Statement[0].Condition.StringEquals["oidc.datafy.io:sub"] == "datafy.io/123e4567-e89b-12d3-a456-426614174000"
    error_message = "Surrounding whitespace in account_id should not leak into the trusted subject"
  }
}

run "trust_policy_shape" {
  assert {
    condition     = jsondecode(aws_iam_role.datafy.assume_role_policy).Statement[0].Principal.Federated == aws_iam_openid_connect_provider.datafy.arn
    error_message = "The trust policy must federate against the OIDC provider this module creates"
  }

  assert {
    condition     = jsondecode(aws_iam_role.datafy.assume_role_policy).Statement[0].Action == "sts:AssumeRoleWithWebIdentity"
    error_message = "The role should only be assumable via web identity"
  }

  assert {
    condition     = jsondecode(aws_iam_role.datafy.assume_role_policy).Statement[0].Condition.StringEquals["oidc.datafy.io:aud"] == "sts.amazonaws.com"
    error_message = "The trust policy should require the sts.amazonaws.com audience"
  }
}

run "condition_keys_come_from_the_provider_arn" {
  variables {
    oidc_url = "https://oidc.example.com"
  }

  # The condition keys are derived from the provider ARN, not from oidc_url, so
  # a custom url must not change them.
  assert {
    condition     = can(jsondecode(aws_iam_role.datafy.assume_role_policy).Statement[0].Condition.StringEquals["oidc.datafy.io:sub"])
    error_message = "Condition keys should be derived from the OIDC provider ARN"
  }
}

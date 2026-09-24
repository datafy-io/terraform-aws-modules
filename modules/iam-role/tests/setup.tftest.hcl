# Sanity check that the module plans and applies against mocked AWS, and that
# the resources it creates carry the expected identity and OIDC wiring.

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

run "defaults" {
  assert {
    condition     = aws_iam_role.datafy.name == "DatafyIORole"
    error_message = "Default role name should be DatafyIORole, got ${aws_iam_role.datafy.name}"
  }

  assert {
    condition     = aws_iam_openid_connect_provider.datafy.url == "https://oidc.datafy.io"
    error_message = "Default OIDC url should be https://oidc.datafy.io"
  }

  assert {
    condition     = aws_iam_openid_connect_provider.datafy.client_id_list == toset(["sts.amazonaws.com"])
    error_message = "OIDC provider should only trust the sts.amazonaws.com audience"
  }

  assert {
    condition     = aws_iam_role_policy.datafy.name == "DatafyIOPolicy"
    error_message = "Inline policy should be named DatafyIOPolicy"
  }

  assert {
    condition     = aws_iam_role_policy.datafy_validation.name == "DatafyIOValidationPolicy"
    error_message = "Validation policy should be named DatafyIOValidationPolicy"
  }
}

run "overrides" {
  variables {
    role_name = "CustomDatafyRole"
    oidc_url  = "https://oidc.example.com"
  }

  assert {
    condition     = aws_iam_role.datafy.name == "CustomDatafyRole"
    error_message = "role_name should override the default role name"
  }

  assert {
    condition     = aws_iam_openid_connect_provider.datafy.url == "https://oidc.example.com"
    error_message = "oidc_url should override the default OIDC url"
  }
}

run "outputs" {
  assert {
    condition     = output.role_name == aws_iam_role.datafy.name
    error_message = "role_name output should mirror the role resource"
  }

  assert {
    condition     = output.role_arn == aws_iam_role.datafy.arn
    error_message = "role_arn output should mirror the role resource"
  }

  assert {
    condition     = output.oidc_provider_arn == aws_iam_openid_connect_provider.datafy.arn
    error_message = "oidc_provider_arn output should mirror the OIDC provider resource"
  }
}

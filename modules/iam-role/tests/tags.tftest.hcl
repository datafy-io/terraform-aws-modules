# Caller tags are merged onto every resource, and are allowed to win over the
# datafy:* tags the module derives.

mock_provider "aws" {
  mock_resource "aws_iam_openid_connect_provider" {
    defaults = {
      arn = "arn:aws:iam::123456789012:oidc-provider/oidc.datafy.io"
    }
  }
}

run "no_tags" {
  assert {
    condition     = length(aws_iam_openid_connect_provider.datafy.tags) == 0
    error_message = "The OIDC provider should carry no tags by default"
  }

  assert {
    condition     = keys(aws_iam_role.datafy.tags) == tolist(["datafy:account:id", "datafy:role:level", "datafy:role:scope", "datafy:role:version"])
    error_message = "The role should only carry the derived datafy tags by default"
  }
}

run "caller_tags_are_merged" {
  variables {
    tags = {
      Environment = "test"
      Owner       = "platform"
    }
  }

  assert {
    condition     = aws_iam_role.datafy.tags["Environment"] == "test"
    error_message = "Caller tags should be merged onto the role"
  }

  assert {
    condition     = aws_iam_role.datafy.tags["datafy:role:scope"] == "Global"
    error_message = "Caller tags should not displace the derived datafy tags"
  }

  assert {
    condition     = aws_iam_openid_connect_provider.datafy.tags == tomap({ Environment = "test", Owner = "platform" })
    error_message = "Caller tags should be applied verbatim to the OIDC provider"
  }
}

run "caller_tags_override_derived_tags" {
  variables {
    tags = {
      "datafy:role:scope" = "overridden"
    }
  }

  assert {
    condition     = aws_iam_role.datafy.tags["datafy:role:scope"] == "overridden"
    error_message = "An explicit caller tag should win over the derived value"
  }
}

run "role_version_is_empty_for_local_sources" {
  # role_version is read from .terraform/modules/modules.json and is only
  # populated when the module is consumed from the registry.
  assert {
    condition     = aws_iam_role.datafy.tags["datafy:role:version"] == ""
    error_message = "role_version should degrade to an empty string when there is no registry module record"
  }
}

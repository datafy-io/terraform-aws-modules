# Every validation block in variables.tf gets a case that must be rejected.
# These run at plan time, before any provider call.

mock_provider "aws" {}

run "rejects_unknown_permissions_level" {
  command = plan

  variables {
    permissions_level = "Auditor"
  }

  expect_failures = [var.permissions_level]
}

run "rejects_unknown_permissions_scope" {
  command = plan

  variables {
    permissions_scope = "Zonal"
  }

  expect_failures = [var.permissions_scope]
}

run "rejects_regions_with_global_scope" {
  command = plan

  variables {
    permissions_scope = "Global"
    regions           = ["us-east-1"]
  }

  expect_failures = [var.regions]
}

run "rejects_empty_regions_with_regional_scope" {
  command = plan

  variables {
    permissions_scope = "Regional"
    regions           = []
  }

  expect_failures = [var.regions]
}

run "rejects_unknown_region" {
  command = plan

  variables {
    permissions_scope = "Regional"
    regions           = ["us-east-1", "atlantis-north-1"]
  }

  expect_failures = [var.regions]
}

run "rejects_non_uuid_account_id" {
  command = plan

  variables {
    account_id = "not-a-uuid"
  }

  expect_failures = [var.account_id]
}

run "rejects_empty_role_name" {
  command = plan

  variables {
    role_name = ""
  }

  expect_failures = [var.role_name]
}

run "rejects_non_https_oidc_url" {
  command = plan

  variables {
    oidc_url = "oidc.datafy.io"
  }

  expect_failures = [var.oidc_url]
}

run "accepts_gov_cloud_regions" {
  command = plan

  variables {
    permissions_scope = "Regional"
    regions           = ["us-gov-east-1", "us-gov-west-1", "cn-north-1"]
  }
}

run "accepts_blank_account_id" {
  command = plan

  variables {
    account_id = "   "
  }
}

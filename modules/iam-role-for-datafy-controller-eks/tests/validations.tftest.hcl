# Every validation block in variables.tf gets a case that must be rejected.

mock_provider "aws" {}

variables {
  cluster_name                = "datafy-demo"
  datafy_controller_namespace = "datafy"
}

override_data {
  target = data.aws_eks_cluster.this
  values = {
    identity = [{ oidc = [{ issuer = "https://oidc.eks.us-east-1.amazonaws.com/id/EXAMPLE" }] }]
  }
}

override_data {
  target = data.aws_iam_openid_connect_provider.this
  values = {
    arn = "arn:aws:iam::123456789012:oidc-provider/oidc.eks.us-east-1.amazonaws.com/id/EXAMPLE"
  }
}

run "rejects_empty_cluster_name" {
  command = plan

  variables {
    cluster_name = ""
  }

  expect_failures = [var.cluster_name]
}

run "rejects_empty_namespace" {
  command = plan

  variables {
    datafy_controller_namespace = ""
  }

  expect_failures = [var.datafy_controller_namespace]
}

run "rejects_empty_service_account_name" {
  command = plan

  variables {
    datafy_controller_service_account_name = ""
  }

  expect_failures = [var.datafy_controller_service_account_name]
}

run "accepts_null_role_name" {
  command = plan

  variables {
    role_name = null
  }
}

# The role_name validation cannot reject an empty string: coalesce() skips empty
# values, so coalesce("", " ") is " " and the length check always holds. An
# empty role_name therefore falls back to the derived name instead of failing.
run "empty_role_name_falls_back_to_the_derived_name" {
  variables {
    role_name = ""
  }

  assert {
    condition     = aws_iam_role.this.name == "datafy-demo-datafy-controller-role"
    error_message = "An empty role_name should fall back to <cluster_name>-datafy-controller-role"
  }
}

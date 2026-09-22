# The module discovers the cluster's OIDC issuer and binds a role to one
# Kubernetes service account (IRSA). Both lookups are mocked here, so the tests
# exercise the naming and trust-policy logic without touching AWS.

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

run "derives_role_name_from_cluster" {
  assert {
    condition     = aws_iam_role.this.name == "datafy-demo-datafy-controller-role"
    error_message = "Role name should default to <cluster_name>-datafy-controller-role, got ${aws_iam_role.this.name}"
  }
}

run "explicit_role_name_wins" {
  variables {
    role_name = "custom-controller-role"
  }

  assert {
    condition     = aws_iam_role.this.name == "custom-controller-role"
    error_message = "An explicit role_name should override the derived name"
  }
}

run "trusts_the_cluster_oidc_provider" {
  assert {
    condition     = jsondecode(aws_iam_role.this.assume_role_policy).Statement[0].Principal.Federated == data.aws_iam_openid_connect_provider.this.arn
    error_message = "The trust policy must federate against the cluster's OIDC provider"
  }

  assert {
    condition     = jsondecode(aws_iam_role.this.assume_role_policy).Statement[0].Action == "sts:AssumeRoleWithWebIdentity"
    error_message = "The role should only be assumable via web identity"
  }

  assert {
    condition     = jsondecode(aws_iam_role.this.assume_role_policy).Statement[0].Condition.StringEquals["oidc.eks.us-east-1.amazonaws.com/id/EXAMPLE:aud"] == "sts.amazonaws.com"
    error_message = "Condition keys should be derived from the OIDC provider ARN and require the sts audience"
  }
}

run "binds_the_default_service_account" {
  assert {
    condition     = jsondecode(aws_iam_role.this.assume_role_policy).Statement[0].Condition.StringEquals["oidc.eks.us-east-1.amazonaws.com/id/EXAMPLE:sub"] == "system:serviceaccount:datafy:datafy-controller-sa"
    error_message = "The subject should default to the datafy-controller-sa service account in the given namespace"
  }
}

run "binds_a_custom_service_account" {
  variables {
    datafy_controller_namespace            = "platform"
    datafy_controller_service_account_name = "controller"
  }

  assert {
    condition     = jsondecode(aws_iam_role.this.assume_role_policy).Statement[0].Condition.StringEquals["oidc.eks.us-east-1.amazonaws.com/id/EXAMPLE:sub"] == "system:serviceaccount:platform:controller"
    error_message = "Namespace and service account name should both flow into the trusted subject"
  }
}

run "looks_up_the_requested_cluster" {
  variables {
    cluster_name = "another-cluster"
  }

  assert {
    condition     = data.aws_eks_cluster.this.name == "another-cluster"
    error_message = "The cluster lookup should use cluster_name"
  }
}

run "tags" {
  variables {
    tags = {
      Environment = "test"
    }
  }

  assert {
    condition     = aws_iam_role.this.tags["Environment"] == "test"
    error_message = "Caller tags should be merged onto the role"
  }

  # role_version is read from .terraform/modules/modules.json and is only
  # populated when the module is consumed from the registry.
  assert {
    condition     = aws_iam_role.this.tags["datafy:role:version"] == ""
    error_message = "role_version should degrade to an empty string when there is no registry module record"
  }
}

run "outputs" {
  assert {
    condition     = output.iam_role_name == aws_iam_role.this.name
    error_message = "iam_role_name output should mirror the role resource"
  }

  assert {
    condition     = output.iam_role_arn == aws_iam_role.this.arn
    error_message = "iam_role_arn output should mirror the role resource"
  }
}

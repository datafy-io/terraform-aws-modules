data "aws_eks_cluster" "this" {
  name = var.cluster_name
}

data "aws_iam_openid_connect_provider" "this" {
  url = data.aws_eks_cluster.this.identity[0].oidc[0].issuer
}

locals {
  effective_oidc_provider_arn = data.aws_iam_openid_connect_provider.this.arn
  oidc_provider_url           = split("oidc-provider/", local.effective_oidc_provider_arn)[1]
  role_version = try(
    [
      for m in lookup(jsondecode(file("${path.root}/.terraform/modules/modules.json")), "Modules", []) :
      "v${m.Version}" if try(startswith(m.Source, "registry.terraform.io/datafy-io/terraform-aws-modules/iam-role-for-datafy-controller-eks"), false) && can(m.Version)
    ][0],
    ""
  )
}

resource "aws_iam_role" "this" {
  name = var.role_name
  tags = var.tags
  tags = merge(
    {
      "datafy:role:version" = local.role_version
    },
    var.tags,
  )

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Principal = {
          Federated = local.effective_oidc_provider_arn
        }
        Action = "sts:AssumeRoleWithWebIdentity"
        Condition = {
          StringEquals = {
            "${local.oidc_provider_url}:aud" = "sts.amazonaws.com"
            "${local.oidc_provider_url}:sub" = "system:serviceaccount:${var.datafy_controller_namespace}:${var.datafy_controller_service_account_name}"
          }
        }
      }
    ]
  })
}

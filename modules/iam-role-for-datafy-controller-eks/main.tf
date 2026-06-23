data "aws_eks_cluster" "this" {
  count = var.cluster_name != null ? 1 : 0

  name = var.cluster_name
}

data "aws_iam_openid_connect_provider" "from_cluster" {
  count = var.cluster_name != null ? 1 : 0

  url = data.aws_eks_cluster.this[0].identity[0].oidc[0].issuer
}

data "aws_iam_openid_connect_provider" "from_arn" {
  count = var.oidc_provider_arn != null ? 1 : 0

  arn = var.oidc_provider_arn
}

locals {
  oidc_provider_arn_from_cluster_name = var.cluster_name != null ? data.aws_iam_openid_connect_provider.from_cluster[0].arn : null
  oidc_provider_arn_from_input        = var.oidc_provider_arn != null ? data.aws_iam_openid_connect_provider.from_arn[0].arn : null
  effective_oidc_provider_arn         = coalesce(local.oidc_provider_arn_from_input, local.oidc_provider_arn_from_cluster_name)
  oidc_provider_url                   = split("oidc-provider/", local.effective_oidc_provider_arn)[1]
}

resource "aws_iam_role" "this" {
  name = var.name

  lifecycle {
    precondition {
      condition     = var.cluster_name != null || var.oidc_provider_arn != null
      error_message = "One of cluster_name or oidc_provider_arn must be provided."
    }

    precondition {
      condition = (
        var.cluster_name == null ||
        var.oidc_provider_arn == null ||
        local.oidc_provider_arn_from_input == local.oidc_provider_arn_from_cluster_name
      )
      error_message = "cluster_name and oidc_provider_arn were both provided but do not resolve to the same OIDC provider."
    }
  }

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
            "${local.oidc_provider_url}:sub" = "system:serviceaccount:${var.namespace}:${var.service_account}"
          }
        }
      }
    ]
  })
}

resource "aws_iam_role_policy" "this" {
  count = length(var.permissions) > 0 ? 1 : 0

  name = "${var.name}-inline"
  role = aws_iam_role.this.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      for statement in var.permissions : {
        Effect   = statement.effect
        Action   = statement.actions
        Resource = statement.resources
      }
    ]
  })
}

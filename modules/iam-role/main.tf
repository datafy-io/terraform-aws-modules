locals {
  oidc_provider_url = split("oidc-provider/", aws_iam_openid_connect_provider.datafy.arn)[1]
  regional_condition = var.permissions_scope == "Regional" ? {
    StringEquals = {
      "aws:RequestedRegion" = var.regions
    }
  } : null
  role_version = try(
    [
      for m in lookup(jsondecode(file("${path.root}/.terraform/modules/modules.json")), "Modules", []) :
      "v${m.Version}" if try(startswith(m.Source, "registry.terraform.io/datafy-io/terraform-aws-modules/iam-role"), false) && can(m.Version)
    ][0],
    ""
  )
}

resource "aws_iam_openid_connect_provider" "datafy" {
  url = var.oidc_url
  client_id_list = [
    "sts.amazonaws.com",
  ]
  thumbprint_list = [
    "9e99a48a9960b14926bb7f3b02e22da2b0ab7280",
  ]
  tags = var.tags
}

resource "aws_iam_role" "datafy" {
  name        = var.role_name
  description = "Service Role for Datafy.io"
  tags = merge(
    {
      "datafy:account:id"   = var.account_id
      "datafy:role:scope"   = var.permissions_scope
      "datafy:role:level"   = var.permissions_level
      "datafy:role:version" = local.role_version
    },
    var.tags,
  )

  assume_role_policy = jsonencode({
    Version = "2008-10-17"
    Statement = [
      {
        Sid    = "OIDC"
        Effect = "Allow"
        Principal = {
          Federated = aws_iam_openid_connect_provider.datafy.arn
        }
        Action = "sts:AssumeRoleWithWebIdentity"
        Condition = {
          StringEquals = {
            "${local.oidc_provider_url}:aud" = "sts.amazonaws.com"
            "${local.oidc_provider_url}:sub" = "datafy.io/${var.account_id}"
          }
        }
      }
    ]
  })
}

resource "aws_iam_role_policy" "datafy" {
  name = "DatafyIOPolicy"
  role = aws_iam_role.datafy.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "ec2:DescribeRegions",
          "ec2:DescribeAvailabilityZones",
          "ec2:DescribeInstanceTypes"
        ]
        Resource = "*"
      },
      {
        Effect = "Allow"
        Action = [
          "ec2:DescribeInstances",
          "ec2:DescribeSnapshots",
          "ec2:DescribeTags",
          "ec2:DescribeVolumes",
          "ec2:DescribeVolumeStatus",
          "ec2:DescribeVolumesModifications"
        ]
        Resource  = "*"
        Condition = local.regional_condition
      },
      {
        Effect = var.permissions_level == "Sensor" ? "Deny" : "Allow"
        Action = [
          "ec2:AttachVolume",
          "ec2:DetachVolume",
          "ec2:ModifyVolume",
          "ec2:ModifyInstanceAttribute",
          "ec2:DeleteVolume",
          "ec2:DeleteSnapshot",
          "ec2:CreateVolume",
          "ec2:CreateSnapshot",
          "ec2:CreateSnapshots",
          "ec2:GetConsoleOutput",
          "ebs:StartSnapshot",
          "ebs:PutSnapshotBlock",
          "ebs:CompleteSnapshot",
          "ebs:ListSnapshotBlocks"
        ]
        Resource  = "*"
        Condition = local.regional_condition
      },
      {
        Effect = var.permissions_level == "Sensor" ? "Deny" : "Allow"
        Action = [
          "ec2:CreateTags",
          "ec2:DeleteTags"
        ]
        Resource = [
          "arn:aws:ec2:*:*:instance/*",
          "arn:aws:ec2:*:*:volume/*",
          "arn:aws:ec2:*:*:snapshot/*"
        ]
        Condition = local.regional_condition
      },
      {
        Effect = var.permissions_level == "Sensor" ? "Deny" : "Allow"
        Action = [
          "kms:CreateGrant",
          "kms:GenerateDataKeyWithoutPlaintext",
          "kms:Decrypt",
          "kms:ReEncryptFrom",
          "kms:ReEncryptTo"
        ]
        Resource = [
          "arn:aws:kms:*:*:key/*"
        ]
        Condition = local.regional_condition
      }
    ]
  })
}

resource "aws_iam_role_policy" "datafy_validation" {
  name = "DatafyIOValidationPolicy"
  role = aws_iam_role.datafy.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "iam:GetRole",
          "iam:GetRolePolicy",
          "iam:ListAttachedRolePolicies",
          "iam:ListRolePolicies",
          "iam:SimulatePrincipalPolicy",
          "iam:GetContextKeysForPrincipalPolicy"
        ]
        Resource = aws_iam_role.datafy.arn
      }
    ]
  })
}

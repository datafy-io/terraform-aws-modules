terraform {
  required_version = ">= 1.3.2"
}

module "irsa" {
  source = "../../modules/iam-role-for-datafy-controller-eks"

  name              = "eks-my-app-role"
  oidc_provider_arn = "arn:aws:iam::123456789012:oidc-provider/oidc.eks.us-east-1.amazonaws.com/id/EXAMPLED539D4633E53DE1B716D3041E"
  namespace         = "default"
  service_account   = "my-app-sa"
  permissions = [
    {
      actions = [
        "s3:GetObject",
        "s3:ListBucket"
      ]
      resources = [
        "arn:aws:s3:::my-app-bucket",
        "arn:aws:s3:::my-app-bucket/*"
      ]
    }
  ]
}

module "irsa_cluster_name_only" {
  source = "../../modules/iam-role-for-datafy-controller-eks"

  name            = "eks-datafy-controller-role-cluster"
  cluster_name    = "my-eks-cluster"
  namespace       = "datafy"
  service_account = "datafy-controller-sa"
}

module "irsa_cluster_name_and_arn" {
  source = "../../modules/iam-role-for-datafy-controller-eks"

  name              = "eks-datafy-controller-role-both"
  cluster_name      = "my-eks-cluster"
  oidc_provider_arn = "arn:aws:iam::123456789012:oidc-provider/oidc.eks.us-east-1.amazonaws.com/id/EXAMPLED539D4633E53DE1B716D3041E"
  namespace         = "datafy"
  service_account   = "datafy-controller-sa"
}

output "iam_role_arn" {
  value = module.irsa.iam_role_arn
}

output "iam_role_name" {
  value = module.irsa.iam_role_name
}

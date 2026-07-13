terraform {
  required_version = ">= 1.3.2"
}

module "irsa" {
  source = "../../../aws/iam-role-for-datafy-controller-eks"

  name            = "eks-datafy-controller-role-cluster"
  cluster_name    = "my-eks-cluster"
  namespace       = "datafy"
  service_account = "datafy-controller-sa"
}

output "iam_role_arn" {
  value = module.irsa.iam_role_arn
}

output "iam_role_name" {
  value = module.irsa.iam_role_name
}

terraform {
  required_version = ">= 1.3.2"
}

module "irsa" {
  source = "../../modules/iam-role-for-datafy-controller-eks"

  role_name                              = "eks-datafy-controller-role-cluster"
  cluster_name                           = "my-eks-cluster"
  datafy_controller_namespace            = "datafy"
  datafy_controller_service_account_name = "datafy-controller-sa"
}

output "iam_role_arn" {
  value = module.irsa.iam_role_arn
}

output "iam_role_name" {
  value = module.irsa.iam_role_name
}

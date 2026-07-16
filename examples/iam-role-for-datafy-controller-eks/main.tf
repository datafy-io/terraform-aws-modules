terraform {
  required_version = ">= 1.3.2"
}

module "irsa" {
  source  = "datafy-io/modules/aws//modules/iam-role-for-datafy-controller-eks"
  version = "~> 1.0"

  cluster_name                = "my-eks-cluster"
  datafy_controller_namespace = "datafy-agent"
}

output "iam_role_arn" {
  value = module.irsa.iam_role_arn
}

output "iam_role_name" {
  value = module.irsa.iam_role_name
}
